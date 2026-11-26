# Database schema baseline

## Verified facts

- Intended database: external Supabase PostgreSQL / MySQL, configured through `backend/.env`.
- Database name: `postgres` (Supabase).
- Core tables managed via SQLAlchemy in `backend/app/database/schema.py`:
  - `users`: User profiles (BSUID/phone, name, location, tier, onboarding state, name_changes_count).
  - `user_tiers`: Daily token quotas and sliding window history limits (Free, Pro, Ultra, FPOHead).
  - `daily_token_usage`: User token accounting and daily request tracking.
  - `chat_history`: Persistent conversational memory turns.
  - `app_settings`: Key-value application runtime flags (e.g. `enable_groq_fallback`, `primary_llm_provider`) editable directly via Supabase Table Editor.
- The network endpoint accepted a TCP connection.

## Unverified metadata

Table inventory, columns, keys, foreign keys, indexes, enum/status fields, timestamps, row counts, and sensitive/private tables remain **Blocked/Uncertain** pending authenticated read-only metadata queries.

The database is authoritative; update this document from `INFORMATION_SCHEMA`/read-only inspection only.
