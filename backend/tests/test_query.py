from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_query_returns_grounded_answer_and_session(monkeypatch):
    monkeypatch.setattr(
        "app.main.answer_question",
        lambda question, language: ("Water the crop only when required.", ["crops:1"]),
    )

    response = client.post("/query", json={"question": "How should I water my crop?"})

    assert response.status_code == 200
    assert response.json()["answer"] == "Water the crop only when required."
    assert response.json()["sources"] == ["crops:1"]
    assert response.json()["session_id"]


def test_query_rejects_blank_and_overlong_questions():
    blank = client.post("/query", json={"question": "   "})
    overlong = client.post("/query", json={"question": "a" * 1001})

    assert blank.status_code == 422
    assert overlong.status_code == 422


def test_answer_question_requires_groq_api_key(monkeypatch):
    from app.services import query

    monkeypatch.setattr(query, "LLM_PROVIDER", "groq")
    monkeypatch.setattr(query, "GROQ_API_KEY", None)
    import pytest
    with pytest.raises(RuntimeError, match="Groq API key"):
        query.answer_question("How to grow tomatoes?", "en")


def test_answer_question_requires_gemini_api_key(monkeypatch):
    from app.services import query

    monkeypatch.setattr(query, "LLM_PROVIDER", "gemini")
    monkeypatch.setattr(query, "GEMINI_API_KEY", None)
    monkeypatch.setattr(query, "is_groq_fallback_enabled", lambda: False)
    import pytest
    with pytest.raises(RuntimeError, match="Gemini API key"):
        query.answer_question("How to grow tomatoes?", "en")


def test_answer_question_generates_gemini_answer(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query
    from app.rag.retrieval import RetrievedRecord

    monkeypatch.setattr(query, "LLM_PROVIDER", "gemini")
    monkeypatch.setattr(query, "GEMINI_API_KEY", "mock_gemini_key")
    monkeypatch.setattr(query, "GEMINI_MODEL", "gemini-3.5-flash-lite")
    monkeypatch.setattr(
        query,
        "retrieve",
        lambda q: [RetrievedRecord(source_table="crops", source_id=1, content="Tomato guide", score=0.95)],
    )

    mock_client = MagicMock()
    mock_choice = MagicMock()
    mock_choice.message.content = "Plant seeds with 1-inch spacing in rich soil."
    mock_client.chat.completions.create.return_value.choices = [mock_choice]

    monkeypatch.setattr(query, "get_gemini_client", lambda: mock_client)

    answer, sources = query.answer_question("How to grow tomatoes?", "en")

    assert answer == "Plant seeds with 1-inch spacing in rich soil."
    assert sources == ["crops:1"]
    mock_client.chat.completions.create.assert_called_once()
    call_kwargs = mock_client.chat.completions.create.call_args.kwargs
    assert call_kwargs["model"] == "gemini-3.5-flash-lite"
    assert call_kwargs["temperature"] == 0.2


def test_gemini_rate_limit_falls_back_to_groq_when_enabled(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query
    from app.rag.retrieval import RetrievedRecord

    monkeypatch.setattr(query, "LLM_PROVIDER", "gemini")
    monkeypatch.setattr(query, "GEMINI_API_KEY", "mock_gemini_key")
    monkeypatch.setattr(query, "GEMINI_MODEL", "gemini-3.5-flash-lite")
    monkeypatch.setattr(query, "GROQ_API_KEY", "mock_groq_key")
    monkeypatch.setattr(query, "GROQ_MODEL", "qwen/qwen3.8-27b")
    monkeypatch.setattr(query, "is_groq_fallback_enabled", lambda: True)
    monkeypatch.setattr(
        query,
        "retrieve",
        lambda q: [RetrievedRecord(source_table="crops", source_id=2, content="Wheat guide", score=0.90)],
    )

    # Gemini fails with 429 Rate Limit
    mock_gemini = MagicMock()
    mock_gemini.chat.completions.create.side_effect = Exception("429 ResourceExhausted: rate limit exceeded per minute")
    monkeypatch.setattr(query, "get_gemini_client", lambda: mock_gemini)

    # Groq succeeds
    mock_groq = MagicMock()
    mock_choice = MagicMock()
    mock_choice.message.content = "Groq fallback advisory for wheat."
    mock_groq.chat.completions.create.return_value.choices = [mock_choice]
    monkeypatch.setattr(query, "get_groq_client", lambda: mock_groq)

    answer, sources = query.answer_question("How to irrigate wheat?", "en")

    assert answer == "Groq fallback advisory for wheat."
    assert sources == ["crops:2"]
    mock_gemini.chat.completions.create.assert_called_once()
    mock_groq.chat.completions.create.assert_called_once()
    assert mock_groq.chat.completions.create.call_args.kwargs["model"] == "qwen/qwen3.8-27b"


def test_gemini_rate_limit_raises_when_fallback_disabled(monkeypatch):
    from unittest.mock import MagicMock
    import pytest
    from app.services import query
    from app.rag.retrieval import RetrievedRecord

    monkeypatch.setattr(query, "LLM_PROVIDER", "gemini")
    monkeypatch.setattr(query, "GEMINI_API_KEY", "mock_gemini_key")
    monkeypatch.setattr(query, "is_groq_fallback_enabled", lambda: False)
    monkeypatch.setattr(
        query,
        "retrieve",
        lambda q: [RetrievedRecord(source_table="crops", source_id=3, content="Rice guide", score=0.92)],
    )

    mock_gemini = MagicMock()
    mock_gemini.chat.completions.create.side_effect = Exception("429 Quota Exceeded")
    monkeypatch.setattr(query, "get_gemini_client", lambda: mock_gemini)

    with pytest.raises(Exception, match="429 Quota Exceeded"):
        query.answer_question("How to transplant rice?", "en")


def test_app_settings_table_and_ttl_cache():
    from sqlalchemy import create_engine
    from app.database import schema

    test_engine = create_engine("sqlite:///:memory:")
    schema.init_db(test_engine)

    # Verify default seeded setting
    val = schema.get_app_setting("enable_groq_fallback", eng=test_engine)
    assert val == "true"

    # Update setting
    schema.set_app_setting("enable_groq_fallback", "false", eng=test_engine)
    updated_val = schema.get_app_setting("enable_groq_fallback", eng=test_engine)
    assert updated_val == "false"


def test_answer_question_generates_groq_answer(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query
    from app.rag.retrieval import RetrievedRecord

    monkeypatch.setattr(query, "LLM_PROVIDER", "groq")
    monkeypatch.setattr(query, "GROQ_API_KEY", "mock_groq_key")
    monkeypatch.setattr(query, "GROQ_MODEL", "qwen/qwen3.8-27b")
    monkeypatch.setattr(
        query,
        "retrieve",
        lambda q: [RetrievedRecord(source_table="crops", source_id=1, content="Tomato guide", score=0.95)],
    )

    mock_client = MagicMock()
    mock_choice = MagicMock()
    mock_choice.message.content = "Plant seeds in warm soil."
    mock_client.chat.completions.create.return_value.choices = [mock_choice]

    monkeypatch.setattr(query, "get_groq_client", lambda: mock_client)

    answer, sources = query.answer_question("How to grow tomatoes?", "en")

    assert answer == "Plant seeds in warm soil."
    assert sources == ["crops:1"]
    mock_client.chat.completions.create.assert_called_once()
    call_kwargs = mock_client.chat.completions.create.call_args.kwargs
    assert call_kwargs["model"] == "qwen/qwen3.8-27b"
    assert call_kwargs["temperature"] == 0.2


def test_answer_question_refuses_out_of_scope_coding_query(monkeypatch):
    from app.services import query

    monkeypatch.setattr(query, "GROQ_API_KEY", "mock_groq_key")
    answer, sources = query.answer_question("Write a python script to scrape a website", "en")

    assert "exclusively to Indian agriculture" in answer
    assert sources == ["out-of-scope"]

    # Test the exact calculator app query
    answer2, sources2 = query.answer_question("how to code a calculator app in Python", "en")
    assert "exclusively to Indian agriculture" in answer2
    assert sources2 == ["out-of-scope"]

    # Test sports / crypto query
    answer3, sources3 = query.answer_question("who won the cricket world cup", "en")
    assert "exclusively to Indian agriculture" in answer3
    assert sources3 == ["out-of-scope"]


def test_answer_question_triggers_fallover_when_no_records_found(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query

    monkeypatch.setattr(query, "LLM_PROVIDER", "groq")
    monkeypatch.setattr(query, "GROQ_API_KEY", "mock_groq_key")
    monkeypatch.setattr(query, "GROQ_MODEL", "qwen/qwen3.8-27b")
    monkeypatch.setattr(query, "retrieve", lambda q: [])

    mock_client = MagicMock()
    mock_choice = MagicMock()
    mock_choice.message.content = "⚠️ General Advisory: Keep soil moist.\n\n💡 You can also ask:\n1. How often to water?"
    mock_client.chat.completions.create.return_value.choices = [mock_choice]

    monkeypatch.setattr(query, "get_groq_client", lambda: mock_client)

    answer, sources = query.answer_question("What is dragon fruit cultivation technique?", "en")

    assert "General Advisory" in answer
    assert sources == ["general-advisory"]
    mock_client.chat.completions.create.assert_called_once()
    call_kwargs = mock_client.chat.completions.create.call_args.kwargs
    # Verify the fallover prompt was delivered to the model
    messages = call_kwargs["messages"]
    assert "STRICT DOMAIN RESTRICTIONS" in messages[0]["content"]
    assert "💡 You can also ask:" in messages[0]["content"]


def test_system_prompt_instructs_general_advisory_on_unrelated_sources():
    from app.services import query

    assert "⚠️ General Advisory" in query.SYSTEM_PROMPT
    assert "DO NOT state \"there is no information available in the sources\"" in query.SYSTEM_PROMPT
    assert "sound agricultural best practices" in query.SYSTEM_PROMPT


def test_retrieve_filters_below_threshold(monkeypatch):
    import json
    from unittest.mock import MagicMock
    from app.rag import retrieval

    # Mock embed_query
    monkeypatch.setattr(retrieval, "embed_query", lambda q: [1.0, 0.0, 0.0])

    # Mock db engine returning one high-similarity record and one low-similarity record
    mock_conn = MagicMock()
    mock_conn.execute.return_value.mappings.return_value.all.return_value = [
        {"source_table": "crops", "source_id": 1, "content": "High match", "vector": json.dumps([0.9, 0.1, 0.0])},
        {"source_table": "crops", "source_id": 2, "content": "Low match", "vector": json.dumps([0.1, 0.9, 0.0])},
    ]
    monkeypatch.setattr(retrieval.engine, "connect", MagicMock(return_value=MagicMock(__enter__=lambda s: mock_conn, __exit__=lambda s, *a: None)))

    # Threshold 0.5 should only keep the high match
    results = retrieval.retrieve("test query", min_score=0.5)
    assert len(results) == 1
    assert results[0].source_id == 1


