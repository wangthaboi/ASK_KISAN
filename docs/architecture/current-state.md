# Current architecture

## Implemented

`backend/app/main.py` defines a FastAPI application with root, health, version, table-listing, and anonymous `POST /query` endpoints. Query models are in `backend/app/api/query.py`; orchestration in `backend/app/services/query.py` uses the existing retrieval layer and returns source identifiers. SlowAPI applies a development limit of 10 requests/minute per client IP. Configuration in `backend/app/config.py` loads database and OpenAI settings from `backend/.env`. `backend/app/database/db.py` constructs a SQLAlchemy MySQL URL.

`frontend/` is a Vite React + Tailwind one-screen public query interface. It reads `VITE_API_URL`, defaulting to the local FastAPI URL, and retains only an anonymous session ID in browser session storage.

## Not Yet Implemented

- Persisted conversation context and public source-detail pages
- Authentication, authorization, content-management workflow, and deployment configuration

## Blocked/Uncertain

The configured MySQL endpoint and external OpenAI/model path were not exercised for the new HTTP route, so live query behavior remains unverified. There is no repository-local virtual environment; dependencies were installed in the developer user environment for local tests.
