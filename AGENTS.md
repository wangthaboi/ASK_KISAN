# ASK_KISAN Project Instructions

## Project Identity

ASK_KISAN is an existing farmer-focused AI information and assistance platform and a working prototype for the Build What Moves India initiative. Its purpose is to provide agricultural and crop information/advisories, government scheme information, and eventually personalized farmer services. It is not being rebuilt from scratch.

## Current State: Verify Before Assuming

Always consult the current repository and `docs/` before assuming a component or capability exists. Current documentation indicates:

- A Python backend environment and MySQL connection infrastructure exist.
- The connection configuration requires PyMySQL, but it is not declared in `backend/requirements.txt`.
- MySQL endpoint connectivity has been established; the authoritative schema still requires inspection.
- A frontend, public chat API, RAG/retrieval implementation, authentication, automated tests, and deployment setup are not currently verified/present or implemented.

These are limitations to verify, not assumptions about future implementation.

## Source of Truth

Use this hierarchy:

1. Actual current source code
2. Actual current database/schema
3. Existing configuration
4. Tests that actually exist and pass
5. `docs/` documentation
6. This `AGENTS.md`
7. Codex skills
8. Historical conversations

If sources conflict, inspect the repository and report the discrepancy. Never assume historical architecture remains current.

## Preserve Existing Work

ASK_KISAN contains meaningful work. Do not unnecessarily rebuild the database, recreate tables, delete agricultural data, replace the backend without approval, discard RAG work without inspection, overwrite documentation, or remove working functionality merely to simplify architecture. Before replacing a component, inspect it and explain why replacement is necessary.

## Documentation-First Development

`docs/` is the living documentation system. For meaningful development work, update the relevant documentation automatically:

- Architecture: `docs/architecture/`; database: `docs/database/`; APIs: `docs/api/`; frontend: `docs/frontend/`
- Security/privacy: `docs/security/`; testing: `docs/testing/`; project: `docs/project/`
- Development history: `docs/progress/`; architectural decisions: `docs/adr/`

Update `docs/progress/development-log.md`, `docs/progress/change-log.md`, and `docs/progress/current-state.md` when appropriate. Mark information accurately as **CURRENT / IMPLEMENTED**, **IN PROGRESS**, **PLANNED**, **PROPOSED**, **BLOCKED**, or **UNKNOWN / REQUIRES VERIFICATION**. Never present plans as implementation, testing as completed when it was not run, or security/privacy/DPDP compliance as established without validation.

## Development Workflow

For meaningful work: **Inspect → Understand → Plan → Implement → Test → Document → Review**. Before modifying a component, inspect its implementation and related documentation, identify dependencies and side effects, and prefer the smallest appropriate change. Do not modify unrelated files.

## Architecture and Backend

Treat changes to frameworks, database or API architecture, frontend, RAG/LLM, authentication/authorization, private farmer data, external integrations, deployment, or security as architectural decisions. Explain major changes before implementing them and record significant decisions in `docs/adr/`.

Respect the existing Python backend architecture. Do not add or remove frameworks merely by preference. Before dependency changes, inspect requirements, explain the need, update relevant documentation, and test the resulting environment.

## Database Safety

The database is important project infrastructure. Never drop tables, delete data, recreate the database unnecessarily, silently change database technology, fabricate schema, or assume undocumented columns/relationships. Before database modifications, inspect the current schema, verify relationships and affected data, and document significant changes. If inspection is unavailable, report that limitation rather than guessing.

## Frontend, RAG, and Agricultural Information

When a frontend is introduced, design around real farmer journeys: keep it simple and usable, include loading/error/empty states, keep secrets out of it, and document pages, components, and flows. Do not build unnecessary complexity before the core journey works.

For RAG, authoritative source data is the source of truth; embeddings are retrieval infrastructure. Ground LLM responses in relevant retrieved information and do not fabricate unsupported claims. Government scheme and agricultural claims should be traceable to authoritative sources where appropriate.

Never fabricate crop, pest/disease, or agricultural recommendations; government scheme eligibility, benefits, or application procedures; or agricultural facts. Document authoritative sources and their status where required.

## Security and Private Farmer Data

Design future private farmer-data functionality separately from public agricultural knowledge. Never expose passwords to the LLM, put secrets into prompts, commit API keys, hard-code credentials, or expose private data unnecessarily. Future private-data access should consider authentication, authorization, least privilege, secure tokenization/authorization mechanisms, minimization, auditability, consent, privacy, and DPDP requirements. Do not claim legal compliance without validation.

## Prototype, Testing, and Reporting

Balance a demonstrable MVP with maintainability, security, documentation, and usability. Do not let enterprise complexity block the MVP, but do not create avoidable security or architectural debt for speed.

Only claim testing that actually occurred. As the project evolves, cover backend, APIs, database, frontend, retrieval/RAG, and security-sensitive functionality as appropriate, and update `docs/testing/` for meaningful testing changes.

After meaningful tasks, report what changed, files changed, tests run, documentation updated, architectural decisions, known limitations, and remaining risks.

## No Autonomous Destructive Changes

Do not drop databases, delete tables or large amounts of data, remove major components, migrate frameworks, change production configuration, or expose secrets without explicit approval.

## Final Principle

Keep this file concise; detailed technical guidance belongs in `docs/`, and specialized workflows may later live under `.agents/skills/`.

