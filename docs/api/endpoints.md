# Endpoint reference

| Method | Path | Current behavior | Status |
| --- | --- | --- | --- |
| GET | `/` | Returns welcome message and running status. | Implemented |
| GET | `/health` | Returns healthy/online status. | Implemented |
| GET | `/version` | Returns API name and version `1.0.0`. | Implemented |
| GET | `/tables` | Calls database helper to return `SHOW TABLES` results. | Implemented; database-dependent |
| POST | `/query` | Validates an anonymous farmer question, retrieves grounded source material, and returns an AI answer with source identifiers. | Implemented; requires configured database and OpenAI credentials |

## `POST /query`

This development-only public endpoint has no authentication. It is limited to **10 requests per minute per client IP**.

Request:

```json
{
  "question": "How should I water rice?",
  "language": "en",
  "session_id": "optional-client-session-id"
}
```

- `question` is required, trimmed, and limited to 1,000 characters.
- `language` is optional and defaults to `en`.
- `session_id` is optional and limited to 128 characters. It provides anonymous, client-managed continuity only; conversation history is not stored or used by the backend yet.

Successful response:

```json
{
  "answer": "…",
  "sources": ["crop_production_guides:8"],
  "session_id": "2fc0d539-1f2b-4e86-8f95-5c6876285dca"
}
```

`sources` is `null` when no retrieved record supported the response. Source values identify the authoritative table and record ID without exposing database connection details. The route returns `422` for invalid input, `429` when rate-limited, and `503` when its retrieval, database, or model dependency is unavailable.
