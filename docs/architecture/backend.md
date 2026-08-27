# Backend

## Implemented

- Python FastAPI application at `backend/app/main.py`, including anonymous `POST /query`.
- Database engine construction through SQLAlchemy at `backend/app/database/db.py`.
- Environment loading at `backend/app/config.py`.
- OpenAI terminal chat and embedding scripts in `backend/app/scripts/`.
- Query orchestration at `backend/app/services/query.py`, which uses existing retrieval, limits answer generation to supplied context, and returns table/record source references.
- SlowAPI rate limiting at 10 requests/minute per client IP for the public query endpoint.

## Current limitations

The API has no persisted conversation layer or authentication. CORS is configured through the `CORS_ORIGINS` environment variable and defaults to local Vite origins. The `/tables` endpoint calls `SHOW TABLES` when invoked; it is a development helper and not a public product endpoint.

## Planned

Persisted conversations, authentication, auditable source details, and deployment operations remain planned. Basic Render and Vercel deployment configuration is implemented in `render.yaml` and `docs/deployment.md`.
