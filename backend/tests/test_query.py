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
