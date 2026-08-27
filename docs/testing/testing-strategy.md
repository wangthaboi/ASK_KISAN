# Testing strategy

## Current state

`backend/tests/test_query.py` provides focused API tests for a valid mocked query and validation failures. `pytest` is declared in `backend/requirements.txt`. These tests do not access the database or OpenAI service.

`backend/app/database/test_db.py` is a database table-listing helper, not a conventional automated test. `backend/app/scripts/test_chat.py` is an interactive manual terminal script.

## Proposed strategy

Add focused tests alongside future work: API route tests, retrieval/grounding behavior tests, data-access tests against approved non-production fixtures, security/authorization tests when auth exists, and end-to-end public-chat flow tests. Database inspection and tests must be read-only unless an explicitly approved isolated test database is introduced.
