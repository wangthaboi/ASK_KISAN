import asyncio
import json
import logging
from sqlalchemy import text
from app.database.db import engine
from app.config import OPENAI_API_KEY, EMBEDDING_MODEL

logger = logging.getLogger(__name__)

_model = None


def get_embedding_model():
    """Lazily load FastEmbed model."""
    global _model
    if _model is None:
        try:
            from fastembed import TextEmbedding
            _model = TextEmbedding(model_name="sentence-transformers/all-MiniLM-L6-v2")
        except ImportError:
            pass
    return _model


def generate_embedding(text_to_embed: str) -> list[float]:
    """Generate vector embedding using FastEmbed (default) or OpenAI fallback."""
    model = get_embedding_model()
    if model:
        return [float(x) for x in list(model.embed([text_to_embed]))[0]]

    if OPENAI_API_KEY:
        from openai import OpenAI
        client = OpenAI(api_key=OPENAI_API_KEY)
        return client.embeddings.create(model=EMBEDDING_MODEL, input=text_to_embed).data[0].embedding

    raise RuntimeError("Neither fastembed nor OPENAI_API_KEY is available for embedding generation.")


def sync_unindexed_records(conn) -> int:
    """Extract authoritative text from database tables into vector_embeddings."""
    new_records_count = 0
    is_pg = conn.dialect.name == "postgresql"
    empty_val = "'[]'::jsonb" if is_pg else "'[]'"

    # 1. Crops
    crops = conn.execute(text("""
        SELECT crop_id, crop_name, crop_category, primary_region, scientific_name, 
               crop_duration, growing_duration_days, water_requirement, description
        FROM crops
        WHERE crop_id NOT IN (
            SELECT source_id FROM vector_embeddings WHERE source_table = 'crops'
        )
    """)).mappings().all()

    for c in crops:
        content = (
            f"Crop: {c['crop_name']} ({c['scientific_name'] or 'General'}). "
            f"Category: {c['crop_category'] or 'Agriculture'}. Primary Region: {c['primary_region'] or 'India'}. "
            f"Duration: {c['crop_duration'] or 'Seasonal'} ({c['growing_duration_days'] or 'variable'} days). "
            f"Water Requirement: {c['water_requirement'] or 'Moderate'}. "
            f"Description: {c['description'] or ''}"
        ).strip()
        conn.execute(text(f"""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('crops', :source_id, :content, {empty_val})
        """), {"source_id": c["crop_id"], "content": content})
        new_records_count += 1

    # 2. Crop Production Guides
    guides = conn.execute(text("""
        SELECT g.guide_id, g.crop_id, c.crop_name, g.season, g.soil_requirements, g.seed_rate,
               g.sowing_period, g.irrigation_requirements, g.fertilizer_recommendations, g.harvesting_guidelines
        FROM crop_production_guides g
        JOIN crops c ON g.crop_id = c.crop_id
        WHERE g.guide_id NOT IN (
            SELECT source_id FROM vector_embeddings WHERE source_table = 'crop_production_guides'
        )
    """)).mappings().all()

    for g in guides:
        content = (
            f"Crop Production Guide for {g['crop_name']}: Season: {g['season'] or 'All Seasons'}. "
            f"Soil Requirements: {g['soil_requirements'] or 'Well-drained'}. "
            f"Seed Rate: {g['seed_rate'] or 'Recommended dose'}. "
            f"Sowing Period: {g['sowing_period'] or 'Seasonal'}. "
            f"Irrigation Requirements: {g['irrigation_requirements'] or 'Regular'}. "
            f"Fertilizer Recommendations: {g['fertilizer_recommendations'] or 'Balanced NPK'}. "
            f"Harvesting Guidelines: {g['harvesting_guidelines'] or 'Harvest when mature'}."
        ).strip()
        conn.execute(text(f"""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('crop_production_guides', :source_id, :content, {empty_val})
        """), {"source_id": g["guide_id"], "content": content})
        new_records_count += 1

    # 3. Crop Advisories
    advisories = conn.execute(text("""
        SELECT a.advisory_id, c.crop_name, cat.category_name, s.stage_name, t.trigger_name,
               a.trigger_condition, a.recommendation, a.priority, a.advisory_type, a.source
        FROM crop_advisory a
        JOIN crops c ON a.crop_id = c.crop_id
        LEFT JOIN advisory_categories cat ON a.category_id = cat.category_id
        LEFT JOIN crop_stages s ON a.stage_id = s.stage_id
        LEFT JOIN trigger_types t ON a.trigger_type_id = t.trigger_type_id
        WHERE a.advisory_id NOT IN (
            SELECT source_id FROM vector_embeddings WHERE source_table = 'crop_advisory'
        )
    """)).mappings().all()

    for a in advisories:
        content = (
            f"Advisory for {a['crop_name']} (Category: {a['category_name']}, Stage: {a['stage_name']}, "
            f"Priority: {a['priority']}, Type: {a['advisory_type']}). "
            f"Condition: {a['trigger_condition']}. "
            f"Recommendation: {a['recommendation']}. Source: {a['source'] or 'Ask Kisan Database'}."
        ).strip()
        conn.execute(text(f"""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('crop_advisory', :source_id, :content, {empty_val})
        """), {"source_id": a["advisory_id"], "content": content})
        new_records_count += 1

    # 4. Government Schemes
    schemes = conn.execute(text("""
        SELECT scheme_id, scheme_name, short_name, scheme_level, target_sector,
               eligibility, benefits, required_documents, registration_steps, helplines, official_website
        FROM government_schemes
        WHERE scheme_id NOT IN (
            SELECT source_id FROM vector_embeddings WHERE source_table = 'government_schemes'
        )
    """)).mappings().all()

    for s in schemes:
        content = (
            f"Government Scheme: {s['scheme_name']} ({s['short_name']}). "
            f"Level: {s['scheme_level']}. Sector: {s['target_sector']}. "
            f"Benefits: {s['benefits']}. Eligibility: {s['eligibility']}. "
            f"Documents Required: {s['required_documents']}. "
            f"Registration Steps: {s['registration_steps']}. "
            f"Helplines: {s['helplines']}. Official Website: {s['official_website']}."
        ).strip()
        conn.execute(text(f"""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('government_schemes', :source_id, :content, {empty_val})
        """), {"source_id": s["scheme_id"], "content": content})
        new_records_count += 1

    # 5. Scheme FAQs
    faqs = conn.execute(text("""
        SELECT faq_id, scheme_name, question, answer, category, keywords
        FROM scheme_faqs
        WHERE faq_id NOT IN (
            SELECT source_id FROM vector_embeddings WHERE source_table = 'scheme_faqs'
        )
    """)).mappings().all()

    for f in faqs:
        content = (
            f"FAQ for {f['scheme_name']} ({f['category'] or 'General'}): "
            f"Question: {f['question']} "
            f"Answer: {f['answer']} "
            f"Keywords: {f['keywords'] or ''}"
        ).strip()
        conn.execute(text(f"""
            INSERT INTO vector_embeddings (source_table, source_id, content, vector)
            VALUES ('scheme_faqs', :source_id, :content, {empty_val})
        """), {"source_id": f["faq_id"], "content": content})
        new_records_count += 1

    return new_records_count


def generate_missing_vectors(conn) -> int:
    """Find any rows in vector_embeddings without calculated vectors and embed them."""
    is_pg = conn.dialect.name == "postgresql"
    vector_filter = (
        "vector IS NULL OR vector::text = '[]' OR vector::text = 'null'"
        if is_pg
        else "vector IS NULL OR vector = '[]' OR vector = 'null'"
    )

    rows = conn.execute(
        text(f"""
            SELECT id, source_table, source_id, content
            FROM vector_embeddings
            WHERE {vector_filter}
        """)
    ).fetchall()

    if not rows:
        return 0

    logger.info(f"Computing embeddings for {len(rows)} new/unindexed records...")
    for idx, row in enumerate(rows, start=1):
        embedding = generate_embedding(row.content)
        conn.execute(
            text("""
                UPDATE vector_embeddings
                SET vector = :vector
                WHERE id = :id
            """),
            {
                "vector": json.dumps(embedding),
                "id": row.id
            }
        )
    return len(rows)


def run_sync_pipeline() -> dict[str, int]:
    """Execute complete sync and vector generation in a database transaction."""
    with engine.begin() as conn:
        synced = sync_unindexed_records(conn)
        generated = generate_missing_vectors(conn)
        return {
            "synced_records": synced,
            "generated_vectors": generated
        }


async def auto_sync_embeddings_worker(interval_seconds: int = 300):
    """
    Background worker that runs indefinitely inside FastAPI's event loop.
    Sleeps for interval_seconds (default 5 mins), wakes up to check for unindexed records,
    embeds them in seconds, and returns to sleep.
    """
    logger.info(f"Starting auto-sync embeddings background worker (interval: {interval_seconds}s)...")
    
    # Run once immediately on startup (with brief delay to allow app to finish initializing)
    await asyncio.sleep(2)
    try:
        res = run_sync_pipeline()
        if res["synced_records"] > 0 or res["generated_vectors"] > 0:
            logger.info(f"Initial startup embedding sync completed: {res}")
    except Exception as exc:
        logger.warning(f"Initial startup embedding sync skipped/failed: {exc}")

    while True:
        try:
            await asyncio.sleep(interval_seconds)
            res = run_sync_pipeline()
            if res["synced_records"] > 0 or res["generated_vectors"] > 0:
                logger.info(f"Periodic embedding auto-sync updated records: {res}")
        except asyncio.CancelledError:
            logger.info("Auto-sync embeddings worker received cancellation signal. Stopping.")
            break
        except Exception as exc:
            logger.warning(f"Auto-sync embeddings worker encountered error (will retry next cycle): {exc}")
