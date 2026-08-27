# ASK_KISAN documentation

This directory is the living, repository-grounded record for the ASK_KISAN working prototype for Build What Moves India. It documents what is verified in the repository, what is planned, and what remains unknown. It does not replace source code or the authoritative MySQL database.

## Navigation

- [Project](project/vision.md): purpose, scope, roadmap, and [user roles/journeys](project/user-roles-and-primary-journeys.md)
- [Architecture](architecture/current-state.md): verified system state and target direction
- [Database](database/schema.md): known configuration and inspection limits
- [API](api/api-overview.md): current endpoints
- [Frontend](frontend/overview.md): current implemented interface and planned direction
- [Security](security/security-model.md): current posture and future boundaries
- [Testing](testing/testing-strategy.md): present test assets and planned strategy
- [Progress](progress/current-state.md): current implementation baseline and history

## Status language

- **Implemented**: verified in the repository.
- **In Progress**: active work with verified partial implementation.
- **Planned**: explicitly intended but absent.
- **Proposed**: design direction not yet accepted or implemented.
- **Blocked/Uncertain**: cannot be verified from the repository or available read-only inspection.

Keep these documents updated with meaningful functionality, architecture, database, security, testing, or UX changes. Preserve prior entries in `progress/`; add an ADR only for significant architectural decisions.
