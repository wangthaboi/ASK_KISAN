# Test results

## 2026-08-24 — Documentation baseline inspection

- **Passed:** static inspection of backend source, declared dependencies, existing documentation, and project structure.
- **Passed:** configured MySQL endpoint accepted a TCP connection without exposing credentials.
- **Blocked:** authenticated MySQL metadata queries; no available MySQL client/driver in the current Python environment.
- **Not run:** backend server, terminal chat, embedding update, `/tables`, or any database-changing operation.

No functional application test had been verified in this repository environment before the entry below.

## 2026-08-25 — Public query API and frontend verification

- **Passed:** `python -m pytest tests/test_query.py -q` — 2 tests passed for successful mocked query behavior and invalid question validation.
- **Passed:** a mocked local request loop returned 10 `200` responses followed by `429`, confirming the 10 requests/minute/IP SlowAPI limit without calling the database or OpenAI.
- **Passed:** `npm run build` in `frontend/` — Vite production bundle completed successfully.
- **Passed:** Python byte-compilation of `backend/app` and `backend/tests`.
- **Not run:** a live `/query` call, because it would depend on the configured database and incur an external OpenAI model request.
- **Warning:** FastAPI's test client emitted a Starlette deprecation warning concerning its current `httpx` use; it did not affect test results.

## 2026-08-25 — Live local query and browser verification

- **Passed:** a real `POST /query` request for rice irrigation returned `200`, a model-generated grounded answer, and five retrieved source identifiers from the configured local database.
- **Passed:** Playwright submitted the same question through the rendered Vite frontend; the real answer and source identifiers appeared in the page after the loading state.
- **Passed:** after the hero restyle, the same Playwright flow again displayed the real backend response and all retrieved sources.
- **Passed:** inspected the rendered framed/photo hero screenshot at desktop size.
- **Environment note:** port 8000 was held by an unavailable bound process during browser testing, so the temporary end-to-end server used port 8001 through `VITE_API_URL`; production/default application configuration remains `http://localhost:8000`.
