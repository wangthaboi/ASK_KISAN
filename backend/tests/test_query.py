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

    monkeypatch.setattr(query, "GROQ_API_KEY", None)
    import pytest
    with pytest.raises(RuntimeError, match="Groq API key"):
        query.answer_question("How to grow tomatoes?", "en")


def test_answer_question_generates_groq_answer(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query
    from app.rag.retrieval import RetrievedRecord

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


def test_answer_question_triggers_fallover_when_no_records_found(monkeypatch):
    from unittest.mock import MagicMock
    from app.services import query

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


