# Security model

## Current state

The backend loads database and OpenAI configuration from `.env`. FastAPI CORS currently allows every origin, method, and header, with a source comment indicating this should be restricted for production. No authentication or authorization is implemented.

## Proposed MVP controls

Treat chat input and retrieved content as untrusted; use request validation, rate limits, safe logging, secret isolation, prompt-injection defenses, and production CORS policy. Public chat must not require or solicit identity information.

Administrator and personalized-data access are future capabilities requiring dedicated controls, not extensions of the public chat boundary.
