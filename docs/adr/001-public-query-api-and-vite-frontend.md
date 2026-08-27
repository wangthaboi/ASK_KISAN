# ADR 001: Public query API and Vite frontend

**Status:** Accepted — 2026-08-25

## Context

ASK KISAN had retrieval and a terminal chat script but no public HTTP query contract or farmer-facing UI. The repository had no existing frontend framework to extend.

## Decision

Expose an anonymous `POST /query` FastAPI endpoint with a bounded Pydantic request model and stable table/record source identifiers. It delegates retrieval to the current MySQL JSON-vector implementation and tells the language model to answer only with the retrieved material. Use SlowAPI to limit the endpoint to 10 requests per minute per remote client address during development.

Create a Vite React + Tailwind single-page frontend. The service base URL is read from `VITE_API_URL`, with `http://localhost:8000` as the development default. The browser keeps only the anonymous session identifier in session storage.

## Consequences

The public prototype now has one explicit API contract and a lightweight user interface without inventing a separate vector store or a second knowledge source. The rate limit is an initial abuse control, not a production security boundary; proxy-aware client IP handling, restrictive CORS, authentication, monitoring, and durable conversation storage require production-specific design.
