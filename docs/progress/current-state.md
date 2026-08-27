# Current project state

## Implemented

- Python FastAPI service with root, health, version, and database table-listing endpoints.
- Public `POST /query` endpoint with bounded anonymous request validation, source identifiers, and SlowAPI rate limiting.
- MySQL connection construction from `.env` through SQLAlchemy.
- Terminal OpenAI chat script and embedding-generation script.
- Embedding script logic that expects `vector_embeddings` fields `id`, `content`, and `vector`.
- Development documentation baseline under `docs/`.
- Vite React + Tailwind public Ask Kisan interface under `frontend/`.

## In Progress

No application feature is verified as actively in progress in the repository. Product roles and farmer journeys have been documented as design work.

## Planned / Proposed

- Persisted anonymous follow-ups and human-readable/public source details.
- Content review/administration workflow.
- Authentication and consent-based personalized services, after the public MVP.
- Deployment configuration and production security controls.

## Blocked / Uncertain

- Database schema, content, relationships, and vector-table reality are unverified because authenticated read-only inspection could not run from the current environment.
- No repository-local Python virtual environment is present. The declared dependencies were installed in the developer user environment to run targeted tests.
- The MySQL endpoint is TCP-reachable, but query connectivity is unverified.

## Known limitations

The query route requires valid database and OpenAI configuration and has not yet been verified against live dependencies in this environment. CORS is currently open to all origins and therefore unsuitable as a production security boundary. The source identifiers supplied by the API are traceability aids, not a public source-detail API.
