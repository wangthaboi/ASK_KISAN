# Database architecture

## Implemented configuration

The backend builds a MySQL SQLAlchemy URL using `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` from `backend/.env`. The safe configured database name observed during inspection is `ask_kisan`.

## Blocked/Uncertain

The server is TCP-reachable, but authenticated read-only metadata queries have not run. Tables, constraints, content domains, and private-data boundaries therefore remain unknown. No local database file, migration, or SQL schema dump exists in the repository.

Do not infer or alter schema from application expectations.
