"""Tests for user onboarding, daily token limits, and multi-turn chat history."""

import pytest
from unittest.mock import MagicMock
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import schema, db
from app.services import user_service, token_service, history_service, query

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_database(monkeypatch):
    """Use an isolated in-memory SQLite database with StaticPool for each test."""
    test_engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        echo=False,
    )
    monkeypatch.setattr(db, "engine", test_engine)
    monkeypatch.setattr(schema, "engine", test_engine)
    monkeypatch.setattr(user_service, "engine", test_engine)
    monkeypatch.setattr(token_service, "engine", test_engine)
    monkeypatch.setattr(history_service, "engine", test_engine)
    schema.init_db(test_engine)
    yield test_engine


def test_user_onboarding_state_machine():
    phone = "919988776655"

    # Step 1: New user created
    user = user_service.get_or_create_user(phone)
    assert user["user_id"] == phone
    assert user["onboarding_step"] == "ask_name"
    assert user["is_new"] is True

    # First interaction: bot prompts for government name
    prompt1 = user_service.handle_onboarding_turn(user, "Hello")
    assert "official full name (government name)" in prompt1

    # Step 2: Farmer replies with name
    user = user_service.get_or_create_user(phone)
    user["is_new"] = False
    prompt2 = user_service.handle_onboarding_turn(user, "Ramesh Patel")
    assert "Thank you, Ramesh Patel!" in prompt2
    assert "District and State" in prompt2

    # Verify user table updated
    updated_user = user_service.get_or_create_user(phone)
    assert updated_user["name"] == "Ramesh Patel"
    assert updated_user["onboarding_step"] == "ask_location"

    # Step 3: Farmer replies with location
    prompt3 = user_service.handle_onboarding_turn(updated_user, "Anand, Gujarat")
    assert "Welcome to ASK KISAN, Ramesh Patel!" in prompt3
    assert "Anand, Gujarat" in prompt3

    # Verify onboarding completed
    completed_user = user_service.get_or_create_user(phone)
    assert completed_user["location"] == "Anand, Gujarat"
    assert completed_user["onboarding_step"] == "completed"

    # Step 4: Next question returns None (proceeds to standard RAG)
    res = user_service.handle_onboarding_turn(completed_user, "How to grow cotton?")
    assert res is None


def test_onboarding_saves_chat_history_and_initializes_usage():
    phone = "919876500000"
    answer, sources = query.answer_question("Namaste", "auto", user_id=phone, phone_number=phone)
    assert "official full name" in answer
    assert sources == ["onboarding"]

    # Verify chat history saved user prompt and bot greeting
    hist = history_service.get_recent_history(phone)
    assert len(hist) == 2
    assert hist[0]["role"] == "user"
    assert hist[0]["content"] == "Namaste"
    assert hist[1]["role"] == "assistant"
    assert "official full name" in hist[1]["content"]

    # Verify daily token usage initialized with 1 request
    has_quota, used, limit = token_service.check_daily_quota(phone, "Free")
    assert has_quota is True
    assert used == 0


def test_token_quota_enforcement():
    phone = "919123456789"
    user_service.get_or_create_user(phone)

    # Initial quota check for Free tier (10,000 tokens)
    has_quota, used, limit = token_service.check_daily_quota(phone, "Free")
    assert has_quota is True
    assert used == 0
    assert limit == 10000

    # Consume 4,000 tokens
    token_service.record_token_usage(phone, 4000)
    has_quota, used, limit = token_service.check_daily_quota(phone, "Free")
    assert has_quota is True
    assert used == 4000

    # Consume 7,000 more tokens (Total: 11,000 > 10,000)
    token_service.record_token_usage(phone, 7000)
    has_quota, used, limit = token_service.check_daily_quota(phone, "Free")
    assert has_quota is False
    assert used == 11000

    # Friendly quota message
    msg = token_service.get_quota_exceeded_message("Ramesh", "Free", limit)
    assert "daily limit of 10,000 tokens" in msg
    assert "automatically reset tomorrow at midnight" in msg


def test_user_tier_history_limit_fallback(monkeypatch):
    """Verify tier limit fetch succeeds normally and returns default 6 on DB exception."""
    # Normal execution (with seeded tiers)
    limit = user_service.get_user_tier_history_limit("Free")
    assert limit == 6

    # When DB throws OperationalError / Exception
    broken_engine = MagicMock()
    broken_engine.begin.side_effect = Exception("DB connection timeout")
    monkeypatch.setattr(user_service, "engine", broken_engine)

    fallback_limit = user_service.get_user_tier_history_limit("Free")
    assert fallback_limit == 6


def test_chat_history_sliding_window():
    phone = "919876543210"
    user_service.get_or_create_user(phone)

    # Save 4 conversation turns (8 messages)
    for i in range(1, 5):
        history_service.save_chat_turn(phone, "user", f"Question {i}")
        history_service.save_chat_turn(phone, "assistant", f"Answer {i}")

    # Fetch with limit = 4 (should return last 2 turns in chronological order)
    history = history_service.get_recent_history(phone, limit=4)
    assert len(history) == 4
    assert history[0] == {"role": "user", "content": "Question 3"}
    assert history[1] == {"role": "assistant", "content": "Answer 3"}
    assert history[2] == {"role": "user", "content": "Question 4"}
    assert history[3] == {"role": "assistant", "content": "Answer 4"}


def test_query_integration_with_user_onboarding(monkeypatch):
    monkeypatch.setattr(query, "LLM_PROVIDER", "groq")
    monkeypatch.setattr(query, "GROQ_API_KEY", "mock_groq_key")
    phone = "919000111222"

    # Turn 1: New user gets onboarding name prompt
    res1 = client.post("/query", json={"question": "Namaste", "user_id": phone})
    assert res1.status_code == 200
    assert "official full name (government name)" in res1.json()["answer"]
    assert res1.json()["sources"] == ["onboarding"]

    # Turn 2: User provides name
    res2 = client.post("/query", json={"question": "Suresh Kumar", "user_id": phone})
    assert res2.status_code == 200
    assert "Thank you, Suresh Kumar!" in res2.json()["answer"]
    assert "District and State" in res2.json()["answer"]

    # Turn 3: User provides location
    res3 = client.post("/query", json={"question": "Nashik, Maharashtra", "user_id": phone})
    assert res3.status_code == 200
    assert "Welcome to ASK KISAN, Suresh Kumar!" in res3.json()["answer"]
    assert "Nashik, Maharashtra" in res3.json()["answer"]

    # Turn 4: User is now completed and asks an agricultural question
    mock_client = MagicMock()
    mock_choice = MagicMock()
    mock_choice.message.content = "Onions in Nashik require well-drained soil."
    mock_choice.usage.total_tokens = 150
    mock_client.chat.completions.create.return_value.choices = [mock_choice]
    mock_client.chat.completions.create.return_value.usage = MagicMock(total_tokens=150)
    monkeypatch.setattr(query, "get_groq_client", lambda: mock_client)

    res4 = client.post("/query", json={"question": "When to sow onions?", "user_id": phone})
    assert res4.status_code == 200
    assert "Onions in Nashik" in res4.json()["answer"]

    # Verify token usage was recorded
    has_quota, used, _ = token_service.check_daily_quota(phone, "Free")
    assert used == 150


def test_user_can_update_location():
    phone = "919333444555"
    user = user_service.get_or_create_user(phone)
    # Complete 3-turn onboarding
    user_service.handle_onboarding_turn(user, "Hello")
    u1 = user_service.get_or_create_user(phone)
    user_service.handle_onboarding_turn(u1, "Anil Sharma")
    u2 = user_service.get_or_create_user(phone)
    user_service.handle_onboarding_turn(u2, "Bhopal, MP")

    completed_user = user_service.get_or_create_user(phone)
    assert completed_user["onboarding_step"] == "completed"
    assert completed_user["location"] == "Bhopal, MP"

    # Farmer asks to change location
    req_prompt = user_service.handle_onboarding_turn(completed_user, "I want to change my location")
    assert "Please enter your new location" in req_prompt

    # Farmer provides new location
    updating_user = user_service.get_or_create_user(phone)
    assert updating_user["onboarding_step"] == "updating_location"
    conf_prompt = user_service.handle_onboarding_turn(updating_user, "Indore, Madhya Pradesh")
    assert "successfully updated to Indore, Madhya Pradesh" in conf_prompt

    # Verify database has new location
    final_user = user_service.get_or_create_user(phone)
    assert final_user["location"] == "Indore, Madhya Pradesh"
    assert final_user["onboarding_step"] == "completed"


def test_user_can_update_name_only_once_with_aadhar_requirement():
    phone = "919777888999"
    user = user_service.get_or_create_user(phone)
    # Complete 3-turn onboarding
    user_service.handle_onboarding_turn(user, "Hello")
    u1 = user_service.get_or_create_user(phone)
    user_service.handle_onboarding_turn(u1, "Karan Singh")
    u2 = user_service.get_or_create_user(phone)
    user_service.handle_onboarding_turn(u2, "Jaipur, Rajasthan")

    completed_user = user_service.get_or_create_user(phone)
    assert completed_user["name_changes_count"] == 0

    # First name change request
    req1 = user_service.handle_onboarding_turn(completed_user, "Please update my name")
    assert "name changes can only be performed once" in req1
    assert "Aadhaar card or equivalent government-issued document" in req1

    # Farmer submits official name
    updating_user = user_service.get_or_create_user(phone)
    assert updating_user["onboarding_step"] == "updating_name"
    conf1 = user_service.handle_onboarding_turn(updating_user, "Karan Singh Rathore")
    assert "Your official name has been updated" in conf1
    assert "Karan Singh Rathore" in conf1

    # Verify database state
    updated_user = user_service.get_or_create_user(phone)
    assert updated_user["name"] == "Karan Singh Rathore"
    assert updated_user["name_changes_count"] == 1
    assert updated_user["onboarding_step"] == "completed"

    # Second name change request must be refused
    req2 = user_service.handle_onboarding_turn(updated_user, "Change my name again")
    assert "already been updated once" in req2
    assert "contact Ask Kisan Admin" in req2
    assert "support@askkisan.in" in req2

    # Verify name did not change
    after_attempt = user_service.get_or_create_user(phone)
    assert after_attempt["name"] == "Karan Singh Rathore"
    assert after_attempt["name_changes_count"] == 1


def test_user_migration_from_phone_to_bsuid():
    """Verify that when a user previously tracked by phone number sends a BSUID,

    their profile, onboarding state, and chat history migrate to the BSUID with zero duplicate accounts.
    """
    import uuid
    from app.services import history_service, token_service
    from app.database.schema import users_table
    from app.database.db import engine
    from sqlalchemy import select

    phone = f"9198{uuid.uuid4().hex[:8]}"
    bsuid = f"IN.{uuid.uuid4().hex[:16]}"

    # 1. User starts out with only phone number
    user = user_service.get_or_create_user(phone)
    assert user["user_id"] == phone
    assert user["onboarding_step"] == "ask_name"

    # Complete onboarding
    user["is_new"] = False
    user_service.handle_onboarding_turn(user, "Suresh Kumar")
    u_loc = user_service.get_or_create_user(phone)
    user_service.handle_onboarding_turn(u_loc, "Nashik, Maharashtra")

    # Save a chat turn and token usage under phone
    history_service.save_chat_turn(phone, "user", "How to grow onions?", tokens=10)
    history_service.save_chat_turn(phone, "assistant", "Use drip irrigation.", tokens=25)
    token_service.record_token_usage(phone, 35)

    # Verify state under phone ID
    user_before = user_service.get_or_create_user(phone)
    assert user_before["name"] == "Suresh Kumar"
    assert user_before["location"] == "Nashik, Maharashtra"
    assert user_before["onboarding_step"] == "completed"

    # 2. Next request arrives with BSUID and the same phone number
    migrated_user = user_service.get_or_create_user(user_id=bsuid, phone_number=phone)

    # 3. Verify user profile was migrated, not duplicated
    assert migrated_user["user_id"] == bsuid
    assert migrated_user["phone_number"] == phone
    assert migrated_user["name"] == "Suresh Kumar"
    assert migrated_user["location"] == "Nashik, Maharashtra"
    assert migrated_user["onboarding_step"] == "completed"

    # Verify in DB that old phone record is gone and only BSUID record exists
    with engine.begin() as conn:
        old_record = conn.execute(
            select(users_table).where(users_table.c.user_id == phone)
        ).fetchone()
        assert old_record is None, "Old phone user_id row should be deleted after migration"

        new_record = conn.execute(
            select(users_table).where(users_table.c.user_id == bsuid)
        ).mappings().fetchone()
        assert new_record is not None
        assert new_record["name"] == "Suresh Kumar"

    # Verify history and token usage carried over to BSUID
    history = history_service.get_recent_history(bsuid)
    assert len(history) == 2
    assert history[0]["content"] == "How to grow onions?"
    assert history[1]["content"] == "Use drip irrigation."


