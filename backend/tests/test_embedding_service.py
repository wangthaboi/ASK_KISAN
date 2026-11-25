"""Unit tests for automated vector embedding sync service and endpoints."""

import json
import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.pool import StaticPool

from app.main import app
from app.services import embedding_service
from app.database import db

client = TestClient(app)


@pytest.fixture
def mock_embedding_db(monkeypatch):
    """Create an isolated in-memory SQLite database with agricultural tables for testing."""
    test_engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        echo=False,
    )
    monkeypatch.setattr(db, "engine", test_engine)
    monkeypatch.setattr(embedding_service, "engine", test_engine)

    with test_engine.begin() as conn:
        conn.execute(text("""
            CREATE TABLE crops (
                crop_id INTEGER PRIMARY KEY,
                crop_name VARCHAR(100),
                crop_category VARCHAR(100),
                primary_region VARCHAR(100),
                scientific_name VARCHAR(255),
                crop_duration VARCHAR(100),
                growing_duration_days INT,
                water_requirement TEXT,
                description TEXT
            );
        """))
        conn.execute(text("""
            CREATE TABLE advisory_categories (
                category_id INTEGER PRIMARY KEY,
                category_name VARCHAR(100) UNIQUE
            );
        """))
        conn.execute(text("""
            CREATE TABLE crop_stages (
                stage_id INTEGER PRIMARY KEY,
                stage_name VARCHAR(100) UNIQUE
            );
        """))
        conn.execute(text("""
            CREATE TABLE trigger_types (
                trigger_type_id INTEGER PRIMARY KEY,
                trigger_name VARCHAR(100) UNIQUE
            );
        """))
        conn.execute(text("""
            CREATE TABLE crop_production_guides (
                guide_id INTEGER PRIMARY KEY,
                crop_id INT,
                season TEXT,
                soil_requirements TEXT,
                seed_rate TEXT,
                sowing_period TEXT,
                irrigation_requirements TEXT,
                fertilizer_recommendations TEXT,
                harvesting_guidelines TEXT
            );
        """))
        conn.execute(text("""
            CREATE TABLE crop_advisory (
                advisory_id INTEGER PRIMARY KEY,
                crop_id INT,
                category_id INT,
                stage_id INT,
                trigger_type_id INT,
                trigger_condition VARCHAR(255),
                recommendation TEXT,
                priority VARCHAR(20),
                advisory_type VARCHAR(50),
                source VARCHAR(255)
            );
        """))
        conn.execute(text("""
            CREATE TABLE government_schemes (
                scheme_id INTEGER PRIMARY KEY,
                scheme_name VARCHAR(255),
                short_name VARCHAR(50),
                scheme_level VARCHAR(20),
                target_sector VARCHAR(100),
                eligibility TEXT,
                benefits TEXT,
                required_documents TEXT,
                registration_steps TEXT,
                helplines TEXT,
                official_website VARCHAR(255)
            );
        """))
        conn.execute(text("""
            CREATE TABLE scheme_faqs (
                faq_id INTEGER PRIMARY KEY,
                scheme_name VARCHAR(100),
                question TEXT,
                answer TEXT,
                category VARCHAR(100),
                keywords TEXT
            );
        """))
        conn.execute(text("""
            CREATE TABLE vector_embeddings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                source_table VARCHAR(100),
                source_id INT,
                content TEXT,
                vector TEXT
            );
        """))

    yield test_engine


def test_sync_unindexed_records(mock_embedding_db):
    """Verify that newly inserted records across tables are synced to vector_embeddings."""
    with mock_embedding_db.begin() as conn:
        # Insert a new crop
        conn.execute(text("""
            INSERT INTO crops (crop_id, crop_name, crop_category, primary_region, scientific_name, crop_duration, growing_duration_days, water_requirement, description)
            VALUES (1, 'Tea', 'Plantation', 'Darjeeling', 'Camellia sinensis', 'Perennial', 1825, 'High', 'Perennial tea bush.');
        """))
        # Insert a production guide
        conn.execute(text("""
            INSERT INTO crop_production_guides (guide_id, crop_id, season, soil_requirements, seed_rate, sowing_period, irrigation_requirements, fertilizer_recommendations, harvesting_guidelines)
            VALUES (1, 1, 'Perennial', 'Acidic loam', '12000/ha', 'June-Sept', 'Regular', 'NPK', 'Pluck 2 leaves');
        """))
        # Insert a scheme
        conn.execute(text("""
            INSERT INTO government_schemes (scheme_id, scheme_name, short_name, scheme_level, target_sector, eligibility, benefits, required_documents, registration_steps, helplines, official_website)
            VALUES (1, 'Kisan Scheme', 'KS', 'Central', 'Agriculture', 'Farmers', 'Subsidy', 'Aadhaar', 'Online', '1551', 'https://kisan.gov.in');
        """))

        # Run sync
        synced = embedding_service.sync_unindexed_records(conn)
        assert synced == 3

        # Verify rows in vector_embeddings
        rows = conn.execute(text("SELECT source_table, source_id, content, vector FROM vector_embeddings")).fetchall()
        assert len(rows) == 3
        tables = [r.source_table for r in rows]
        assert "crops" in tables
        assert "crop_production_guides" in tables
        assert "government_schemes" in tables

        # Re-running sync without new data should sync 0
        synced_again = embedding_service.sync_unindexed_records(conn)
        assert synced_again == 0


def test_generate_missing_vectors(mock_embedding_db, monkeypatch):
    """Verify that uncalculated vectors are generated using mock embedding."""
    dummy_vector = [0.123, 0.456, 0.789]
    monkeypatch.setattr(embedding_service, "generate_embedding", lambda text: dummy_vector)

    with mock_embedding_db.begin() as conn:
        conn.execute(text("""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('crops', 1, 'Crop: Tea', '[]');
        """))

        count = embedding_service.generate_missing_vectors(conn)
        assert count == 1

        row = conn.execute(text("SELECT vector FROM vector_embeddings WHERE id = 1")).fetchone()
        assert json.loads(row.vector) == dummy_vector

        # Running again finds nothing to embed
        count_again = embedding_service.generate_missing_vectors(conn)
        assert count_again == 0


def test_run_sync_pipeline_end_to_end(mock_embedding_db, monkeypatch):
    """Verify full end-to-end sync pipeline."""
    dummy_vector = [0.1, 0.2, 0.3]
    monkeypatch.setattr(embedding_service, "generate_embedding", lambda text: dummy_vector)

    with mock_embedding_db.begin() as conn:
        conn.execute(text("""
            INSERT INTO crops (crop_id, crop_name, crop_category, primary_region, scientific_name, crop_duration, growing_duration_days, water_requirement, description)
            VALUES (10, 'Tomato', 'Vegetable', 'Darjeeling Hills', 'Solanum lycopersicum', 'Annual', 120, 'Medium', 'Fresh tomato crop.');
        """))

    results = embedding_service.run_sync_pipeline()
    assert results["synced_records"] == 1
    assert results["generated_vectors"] == 1


def test_sync_embeddings_api_endpoint(mock_embedding_db, monkeypatch):
    """Test the POST /sync-embeddings HTTP endpoint."""
    dummy_vector = [0.5, 0.5, 0.5]
    monkeypatch.setattr(embedding_service, "generate_embedding", lambda text: dummy_vector)

    response = client.post("/sync-embeddings")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert "synced_records" in data
    assert "generated_vectors" in data
