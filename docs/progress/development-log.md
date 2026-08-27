# Development log

## 2026-08-24 — Establish project documentation baseline

### Objective

Create a living documentation structure for the existing ASK_KISAN proof of concept without modifying application code, configuration, or database data.

### Changes Made

- Added the requested documentation hierarchy under `docs/`.
- Added project vision, scope, roadmap, architecture, database, API, frontend, security, testing, and progress baseline documents.
- Preserved the existing `docs/project/user-roles-and-primary-journeys.md` design document.
- Recorded only repository-verified facts and explicit unknowns.

### Reason

Provide an accurate shared foundation while ASK_KISAN evolves from terminal proof of concept to a farmer-facing product.

### Testing

- Inspected project structure and relevant Python source.
- Verified the documentation file inventory after creation.
- Did not run the backend, chat script, embedding script, or database metadata queries.

### Documentation

Created the documentation system represented by `docs/README.md` and its linked sections.

### Status

Completed.

### Notes

Authenticated MySQL schema inspection remains blocked by missing local client/driver packages. The database is authoritative; schema documents intentionally avoid invented table details.

## 2026-08-25 — Public query API and farmer frontend

### Objective

Expose the existing grounded retrieval capability through a bounded public development API and provide the focused Ask Kisan farmer-query interface.

### Changes Made

- Added `POST /query`, Pydantic request/response schemas, a 1,000-character question limit, and 10 requests/minute/IP SlowAPI limiting.
- Added contextual answer generation that uses the existing retrieval layer and returns stable source identifiers.
- Added the Vite React + Tailwind single-page frontend with responsive glass-panel states and environment-configured API URL.
- Added API validation tests and an ADR documenting the interface decision.

### Status

Implemented and locally verified with targeted mocked API tests, rate-limit checks, and a production frontend build. The live database/OpenAI query path remains unverified because it was intentionally not called.

## 2026-08-25 — Live query verification and framed photo hero

### Objective

Verify that the rendered frontend uses the real query path before applying the requested high-impact visual restyle.

### Changes Made

- Traced the existing test-chat and retrieval code. The public API retains the existing retrieval and model services rather than returning mock data.
- Submitted a real rice-irrigation query through `/query` and through the rendered frontend; both returned grounded answers and database source identifiers.
- Restyled the one-screen hero as an inset, layered photo frame with image bleed, dark overlay, floating minimal navigation, guidance badge, high-contrast headline, and search-pill primary action.
- Added a local Unsplash golden-wheat hero image and visible attribution.

### Status

Implemented and verified end to end after the restyle.
