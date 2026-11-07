# ADR 002: Supabase (PostgreSQL) Support and WhatsApp Cloud API Integration

**Status:** Accepted — 2026-10-25

## Context

ASK_KISAN was initially developed targeting an external MySQL instance with application-side JSON vector cosine ranking. To host the application on a free-tier AWS EC2 instance (`t2.micro` / `t3.micro`) without incurring database memory exhaustion, a managed database is required. Supabase provides a managed PostgreSQL environment with pgvector support and connection pooling. Additionally, to serve Indian farmers directly through mobile messaging, a WhatsApp chatbot interface is required.

## Decision

1. **Database Multi-Dialect Support**:
   - Introduce PostgreSQL / Supabase compatibility via `psycopg2-binary` and SQLAlchemy URL normalization.
   - Support `DATABASE_URL` directly in `backend/app/config.py` and `backend/app/database/db.py`, while retaining backward compatibility for MySQL via fallback parameters.
   - Refactor vector retrieval in `backend/app/rag/retrieval.py` to be database-agnostic (`WHERE vector IS NOT NULL`) and remove MySQL-specific functions (`JSON_LENGTH`).
   - Provide a complete PostgreSQL DDL schema with reference seed data in `database/supabase_schema.sql`.

2. **WhatsApp Cloud API Integration**:
   - Implement `GET /whatsapp/webhook` to handle Meta's verification challenge (`hub.mode`, `hub.verify_token`, `hub.challenge`).
   - Implement `POST /whatsapp/webhook` to ingest incoming farmer messages, validate the `X-Hub-Signature-256` HMAC SHA-256 signature, return an immediate `200 OK` response to prevent Meta webhook retries, and process inquiries in the background using FastAPI's `BackgroundTasks`.
   - Dispatch generated, grounded answers back to the farmer's WhatsApp number via Meta's WhatsApp Business Graph API (`https://graph.facebook.com/v20.0/{PHONE_NUMBER_ID}/messages`).

## Consequences

- The application can now be deployed seamlessly to Supabase PostgreSQL or continue running on MySQL.
- Deploying on a 1 GB RAM EC2 free-tier instance is stable because memory-intensive database processes are offloaded to Supabase.
- Farmers can query agricultural advisories and government schemes directly via WhatsApp text messages.
- The webhook is protected with HMAC signature verification to prevent spoofing or unauthorized LLM consumption.
