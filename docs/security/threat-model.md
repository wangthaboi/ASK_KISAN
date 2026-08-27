# Threat model baseline

This is a preliminary **Proposed** model, not a substitute for a repository-grounded security review after implementation.

| Asset/boundary | Primary risk | Required direction |
| --- | --- | --- |
| Public chat input | Abuse, prompt injection, unsafe requests | Validate, rate-limit, constrain model behavior, and return safe limitations. |
| OpenAI/database secrets | Disclosure through source, logs, or errors | Keep in environment configuration and redact from logs/responses. |
| Retrieved knowledge | Poisoned/stale or irrelevant content | Approved sources, review dates, provenance, and retrieval constraints. |
| Future admin workflow | Unauthorized publishing | Strong auth, least privilege, audit trail, review controls. |
| Future private data | Disclosure or unauthorized access | Consent, per-user authorization, encryption, retention and incident controls. |

No user-authenticated attack surface is currently implemented; its future design requires a dedicated update to this document.
