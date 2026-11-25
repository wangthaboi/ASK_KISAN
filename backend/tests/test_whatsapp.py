import hashlib
import hmac
import json
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_whatsapp_webhook_verification_success(monkeypatch):
    monkeypatch.setattr("app.api.whatsapp.WHATSAPP_VERIFY_TOKEN", "test_secret_token_123")

    response = client.get(
        "/whatsapp/webhook",
        params={
            "hub.mode": "subscribe",
            "hub.challenge": "1158201444",
            "hub.verify_token": "test_secret_token_123",
        },
    )

    assert response.status_code == 200
    assert response.text == "1158201444"


def test_whatsapp_webhook_verification_failure(monkeypatch):
    monkeypatch.setattr("app.api.whatsapp.WHATSAPP_VERIFY_TOKEN", "test_secret_token_123")

    response = client.get(
        "/whatsapp/webhook",
        params={
            "hub.mode": "subscribe",
            "hub.challenge": "1158201444",
            "hub.verify_token": "wrong_token",
        },
    )

    assert response.status_code == 403


def test_whatsapp_webhook_receives_text_message(monkeypatch):
    mock_process = AsyncMock()
    monkeypatch.setattr("app.api.whatsapp.process_inbound_message", mock_process)

    payload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "123456789",
                "changes": [
                    {
                        "value": {
                            "messaging_product": "whatsapp",
                            "metadata": {
                                "display_phone_number": "15550269224",
                                "phone_number_id": "987654321",
                            },
                            "messages": [
                                {
                                    "from": "919876543210",
                                    "id": "wamid.test_msg_id",
                                    "timestamp": "1720000000",
                                    "text": {"body": "How do I control potato blight?"},
                                    "type": "text",
                                }
                            ],
                        },
                        "field": "messages",
                    }
                ],
            }
        ],
    }

    response = client.post("/whatsapp/webhook", json=payload)

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    mock_process.assert_called_once_with("919876543210", "How do I control potato blight?")


def test_whatsapp_webhook_ignores_non_text_events():
    payload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "123456789",
                "changes": [
                    {
                        "value": {
                            "messaging_product": "whatsapp",
                            "statuses": [{"id": "wamid.123", "status": "delivered"}],
                        },
                        "field": "messages",
                    }
                ],
            }
        ],
    }

    response = client.post("/whatsapp/webhook", json=payload)
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_whatsapp_webhook_hmac_signature_validation(monkeypatch):
    secret = "my_app_secret"
    monkeypatch.setattr("app.api.whatsapp.WHATSAPP_APP_SECRET", secret)

    payload_data = {"object": "whatsapp_business_account", "entry": []}
    payload_bytes = json.dumps(payload_data).encode("utf-8")

    valid_signature = "sha256=" + hmac.new(
        secret.encode("utf-8"),
        payload_bytes,
        hashlib.sha256,
    ).hexdigest()

    # Valid signature
    response_valid = client.post(
        "/whatsapp/webhook",
        content=payload_bytes,
        headers={"Content-Type": "application/json", "X-Hub-Signature-256": valid_signature},
    )
    assert response_valid.status_code == 200

    # Invalid signature
    response_invalid = client.post(
        "/whatsapp/webhook",
        content=payload_bytes,
        headers={"Content-Type": "application/json", "X-Hub-Signature-256": "sha256=invalid"},
    )
    assert response_invalid.status_code == 403
