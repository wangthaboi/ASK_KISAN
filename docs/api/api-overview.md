# API overview

## Implemented endpoints

The FastAPI app exposes `GET /`, `GET /health`, `GET /version`, `GET /tables`, and public `POST /query`.

`POST /query` is the farmer-facing, anonymous query interface. It retrieves the existing derived vector records, asks the configured language model to answer only from that material, and returns answer text plus source identifiers. It has a 1,000-character question limit and a development rate limit of 10 requests per minute per client IP.

## Not Yet Implemented

There is no persisted conversation API, authentication API, administrator API, human-readable public source/reference API, or API versioning strategy beyond the metadata returned by `/version`.

`/tables` accesses the configured database when called and is a development helper, not a confirmed public-product endpoint.
