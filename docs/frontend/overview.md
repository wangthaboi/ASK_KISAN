# Frontend overview

## Current state

**CURRENT / IMPLEMENTED:** `frontend/` contains a Vite React and Tailwind CSS application. The single public Ask Kisan screen is composed of `AskKisanApp`, `Header`, `SearchBar`, and `ResultPanel`.

It calls `${VITE_API_URL}/query`, falling back to `http://localhost:8000/query`, and renders loading, error, no-source, and answer states. Its anonymous `session_id` persists only for the browser tab/session.

The hero uses the local asset `frontend/public/images/wheat-field-unsplash.jpg`, sourced from the free [Unsplash photograph by N N](https://unsplash.com/photos/the-sun-is-setting-over-a-wheat-field-NzgDuBIzBNw). It is presented with a visible attribution link.

## Proposed MVP responsibility

Provide a simple accessible farmer-facing chat interface that submits a question and optional non-identifying context, displays answer limitations and sources, and supports short-lived follow-up context. Technology selection is not yet decided.
