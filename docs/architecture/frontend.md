# Frontend architecture

## Current state

**CURRENT / IMPLEMENTED:** `frontend/` is a Vite React single-page app styled with Tailwind CSS. It has a centered farmer query interface, result/loading/error states, source-reference chips, keyboard-accessible input, and reduced-motion support.

The frontend reads `VITE_API_URL` and defaults to `http://localhost:8000`. It sends `POST /query` requests and stores only the anonymous server-issued session ID in browser session storage. Copy `frontend/.env.example` to `frontend/.env` to override the local API URL.

## Proposed MVP

The implemented one-screen experience collects a question and automatically supplies the browser language. Crop/district/season fields, deployment hosting, and persisted conversations remain planned.
