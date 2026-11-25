"""WhatsApp Cloud API Webhook Integration for ASK_KISAN."""

from __future__ import annotations

import hashlib
import hmac
import logging
from typing import Any

import httpx
from fastapi import APIRouter, BackgroundTasks, Header, HTTPException, Query, Request, Response
from pydantic import BaseModel

from app.config import (
    WHATSAPP_APP_SECRET,
    WHATSAPP_PHONE_NUMBER_ID,
    WHATSAPP_TOKEN,
    WHATSAPP_VERIFY_TOKEN,
)
from app.services.query import answer_question

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/whatsapp", tags=["whatsapp"])


def verify_meta_signature(payload_bytes: bytes, signature_header: str | None) -> bool:
    """Verify HMAC SHA-256 signature from Meta if WHATSAPP_APP_SECRET is configured."""
    if not WHATSAPP_APP_SECRET:
        # If secret is not set in development, bypass signature check
        return True

    if not signature_header or not signature_header.startswith("sha256="):
        return False

    expected_sig = signature_header.split("sha256=", 1)[1]
    calculated_sig = hmac.new(
        WHATSAPP_APP_SECRET.encode("utf-8"),
        payload_bytes,
        hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(calculated_sig, expected_sig)


async def send_whatsapp_message(to_phone: str, message_text: str) -> bool:
    """Send a text message back to a farmer via Meta WhatsApp Graph API."""
    if not WHATSAPP_TOKEN or not WHATSAPP_PHONE_NUMBER_ID:
        logger.error("WhatsApp credentials not configured; cannot send message.")
        return False

    url = f"https://graph.facebook.com/v20.0/{WHATSAPP_PHONE_NUMBER_ID}/messages"
    headers = {
        "Authorization": f"Bearer {WHATSAPP_TOKEN}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": to_phone,
        "type": "text",
        "text": {
            "preview_url": False,
            "body": message_text,
        },
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(url, json=payload, headers=headers)
            if response.status_code >= 400:
                logger.error(
                    "Meta Graph API error: %d - %s",
                    response.status_code,
                    response.text,
                )
                return False
            return True
    except Exception as exc:
        logger.exception("Failed to dispatch WhatsApp message to %s: %s", to_phone, exc)
        return False


async def process_inbound_message(sender_phone: str, user_text: str) -> None:
    """Process farmer query via RAG service and reply asynchronously."""
    try:
        # Use grounded answer generation from existing ASK_KISAN RAG service
        answer, _ = answer_question(user_text, language="auto")
        await send_whatsapp_message(sender_phone, answer)
    except Exception as exc:
        logger.exception("Error generating RAG answer for WhatsApp user %s: %s", sender_phone, exc)
        fallback = (
            "Namaste. ASK KISAN is temporarily unable to answer questions. "
            "Please try again shortly or contact your local agricultural extension officer."
        )
        await send_whatsapp_message(sender_phone, fallback)


@router.get("/webhook")
async def verify_webhook(
    hub_mode: str | None = Query(None, alias="hub.mode"),
    hub_challenge: str | None = Query(None, alias="hub.challenge"),
    hub_verify_token: str | None = Query(None, alias="hub.verify_token"),
) -> Response:
    """Handle Meta webhook registration challenge."""
    if hub_mode == "subscribe" and hub_verify_token == WHATSAPP_VERIFY_TOKEN and hub_challenge:
        return Response(content=hub_challenge, media_type="text/plain")

    raise HTTPException(status_code=403, detail="Verification token mismatch")


@router.post("/webhook")
async def receive_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
    x_hub_signature_256: str | None = Header(None),
) -> dict[str, str]:
    """Receive incoming webhook events from Meta WhatsApp Cloud API."""
    body_bytes = await request.body()

    # Validate signature if app secret is provided
    if not verify_meta_signature(body_bytes, x_hub_signature_256):
        raise HTTPException(status_code=403, detail="Invalid webhook signature")

    try:
        data: dict[str, Any] = await request.json()
    except Exception:
        return {"status": "ignored"}

    # Meta events format check
    if data.get("object") != "whatsapp_business_account":
        return {"status": "ignored"}

    entries = data.get("entry", [])
    for entry in entries:
        changes = entry.get("changes", [])
        for change in changes:
            value = change.get("value", {})
            messages = value.get("messages", [])
            for message in messages:
                # We only process text messages
                if message.get("type") == "text":
                    sender = message.get("from")
                    text_body = message.get("text", {}).get("body", "").strip()

                    if sender and text_body:
                        # Schedule background processing to keep HTTP 200 response immediate
                        background_tasks.add_task(process_inbound_message, sender, text_body)

    return {"status": "ok"}
