# ASK_KISAN user roles and primary journeys

## Purpose and scope

ASK_KISAN's first official product should help farmers find reliable, understandable agricultural and government-scheme information through a conversational interface. This document defines the product target only; it does not authorize implementation, database changes, authentication, or content-management tooling.

The first release should prioritize public, source-grounded answers over collecting farmer data. Any answer that needs personal identity, eligibility verification, consent, or access to private records is outside the MVP.

## Evidence from the current project

| Finding | Classification | Evidence and implication |
| --- | --- | --- |
| FastAPI service with `/`, `/health`, `/version`, and `/tables` endpoints | **CURRENT** | `backend/app/main.py` contains these endpoints. There is no chat API endpoint. |
| Terminal chat can call OpenAI and produce a general answer | **CURRENT** | `backend/app/scripts/test_chat.py` sends the question to `gpt-4.1-mini`. |
| Query embeddings are generated | **CURRENT** | The terminal script calls the configured embedding model. |
| `vector_embeddings` is expected by an embedding script | **CURRENT** | `generate_embeddings.py` selects `id`, `content`, and `vector`, then updates missing vectors when explicitly run. |
| Retrieved context is part of the chat answer | **PLANNED** | The chat prompt explicitly says retrieved context will be supplied later; no retrieval query is implemented. |
| Frontend, authentication, user accounts, administrator UI, or content workflow | **UNCERTAIN** | None exists in the inspected project folder. No conclusion is made about systems outside it. |
| Database tables and data domains | **UNCERTAIN** | The configured MySQL endpoint is network-reachable, but authenticated metadata inspection could not run in the available local environment. |

## Project user model

### MVP roles

#### 1. Farmer / public user

**Purpose:** obtain reliable public information without an account.

**May:**

- Ask agricultural and government-scheme questions in a conversational interface.
- Provide optional, non-identifying context such as crop, district, season, and language preference for the current conversation.
- Ask follow-up questions within the same conversation.
- Receive a clear answer, uncertainty statement, and source/reference information when available.

**Must not be required to:** create an account, disclose a phone number, reveal government identifiers, or provide private financial/benefit information for the MVP.

**Must not be able to:** change knowledge content, view internal configuration, browse private records, or trigger administrative actions.

#### 2. Administrator / content manager

**Purpose:** maintain the accuracy, provenance, and lifecycle of public knowledge.

**May, once the role is implemented:**

- Create, edit, review, publish, unpublish, and retire public agricultural guidance, scheme information, advisories, and their references.
- Mark content as reviewed and identify its authoritative source and effective/review dates.
- Request controlled re-indexing of approved public knowledge.
- View operational status and content-review queues.

**Must not:** use the content role as blanket access to future farmer-private data, expose API secrets, or publish unreviewed high-risk advice without a defined review policy.

**Classification:** **PROPOSED** for the role and its permissions. No administrator authentication or management capability is currently implemented.

### Roles deliberately deferred

| Role | Classification | Why it is deferred |
| --- | --- | --- |
| Authenticated farmer | **PROPOSED** | A future role requiring an account model, consent, privacy policy, security controls, and a clear personalized benefit. |
| Agricultural reviewer / agronomist | **PROPOSED** | A future role that may be useful for clinical-quality review, but can initially be represented by an administrator workflow with explicit review metadata. |
| Scheme specialist | **PROPOSED** | A future role useful if scheme policy changes require separate governance; not needed for the first public prototype. |
| System operator | **PROPOSED** | A future role; operational access should be separate from content permissions when deployment and monitoring exist. |

## Permission boundaries

| Capability | Farmer / public user | Administrator / content manager | Future authenticated farmer |
| --- | --- | --- | --- |
| Ask public questions | Allowed | Allowed | Allowed |
| Supply crop/district/season for a session | Allowed, optional | Not applicable | Allowed, optionally saved with consent |
| See public sources/references | Allowed | Allowed | Allowed |
| Change public knowledge | Not allowed | Proposed, controlled | Not allowed |
| Manage sources/review status | Not allowed | Proposed, controlled | Not allowed |
| Access private farmer data | Not allowed | Not implied by content role | Only own data, with consent and authorization |
| Change system or secrets | Not allowed | Not implied | Not allowed |

## Public versus personalized information

### Public information — MVP scope

Public answers may use a farmer's voluntarily supplied session context, but must not require identity. Examples include crop cultivation, pest-management basics, fertilizer and irrigation guidance, public government-scheme descriptions, published eligibility rules, application guidance, district-level public advisories, and season-related guidance where an authoritative source is available.

The system should clearly identify when district, crop, season, or date is missing and ask a focused follow-up rather than inventing it. It must distinguish general information from an official eligibility decision.

### Personalized information — future scope

Personalized functionality includes profiles, saved land/crop history, stored location, benefit/application status, account-linked documents, consent records, phone or government identifiers, and recommendations derived from those records. This category requires a separate privacy, consent, authorization, retention, and incident-response design.

**Classification:** all personalized capabilities are **PROPOSED**. The inspected project contains no authenticated user flow or confirmed private-data model.

## Primary journeys

### 1. Anonymous farmer asks an agricultural question — MVP

- **Actor / start:** Farmer opens the public chat and enters a question such as a crop, pest, fertilizer, irrigation, or cultivation question.
- **Inputs:** question; optional current-language, crop, district, season, and date context.
- **Processing:** validate and normalize the request; determine whether enough context exists; retrieve approved public knowledge when retrieval is implemented; generate a concise answer constrained to retrieved material and known limitations.
- **Database/RAG interaction:** **CURRENT** code can generate an embedding; **PLANNED** retrieval of relevant approved content and references. The actual database tables remain **UNCERTAIN** pending metadata inspection.
- **Response:** direct answer, practical next step, necessary caveat, and source/reference link or citation where available.
- **Failure and edge cases:** ambiguous crop/pest, missing seasonal context, unsupported language, outdated/unavailable source, unsafe request, or no relevant content. Ask a clarifying question or state the limitation; do not fabricate advice.
- **Security:** no account or PII required; treat input as untrusted; protect against prompt injection; do not reveal internal prompts, secrets, or database details.

### 2. Farmer asks a crop-specific question — MVP

- **Actor / start:** Farmer asks about a named crop, optionally identifying its growth stage or symptom.
- **Inputs:** crop, question, optional stage, district, season, and symptom description.
- **Processing:** resolve crop and stage where possible; ask one focused clarification if the crop/stage is ambiguous; retrieve crop-specific approved material before answering.
- **Database/RAG interaction:** **PROPOSED** structured crop/stage filters plus retrieval. The presence of crop tables is **UNCERTAIN**.
- **Response:** crop-relevant guidance, scope limits, and escalation advice for severe/uncertain disease or safety-sensitive issues.
- **Failure and edge cases:** local crop name ambiguity, multiple likely pests, conflicting guidance, or missing region/season. Avoid dosage/pesticide instructions unsupported by approved sources.
- **Security:** public-only context; do not infer farm ownership, exact location, or identity.

### 3. Farmer asks about a government scheme — MVP

- **Actor / start:** Farmer asks what a scheme is, who may qualify, what benefits it offers, or how to apply.
- **Inputs:** question, scheme name if known, optional state/district, and desired language.
- **Processing:** retrieve current approved scheme content and its official source; distinguish published eligibility criteria from an eligibility determination.
- **Database/RAG interaction:** **PROPOSED** scheme-content retrieval with source dates and jurisdiction filters. Existing scheme tables are **UNCERTAIN**.
- **Response:** scheme summary, public criteria, benefit summary, official application path, source/date, and a statement that final eligibility is decided by the relevant authority.
- **Failure and edge cases:** ambiguous names, expired/changed schemes, state-specific variants, or no verified source. State uncertainty instead of guessing.
- **Security:** never request Aadhaar, bank, application, or benefit details in the public chat.

### 4. Farmer asks a district-specific question — MVP where verified district data exists

- **Actor / start:** Farmer asks for district-relevant advice or supplies a district after being asked.
- **Inputs:** district, state when needed to disambiguate, question, and optional crop/season.
- **Processing:** normalize the district/state; restrict retrieval to authoritative local content where available; otherwise provide general guidance with a clear limitation.
- **Database/RAG interaction:** **PROPOSED** geographic filtering. District tables/data are **UNCERTAIN**.
- **Response:** local result with its applicability date, or general information plus a request for the appropriate local extension/authority channel.
- **Failure and edge cases:** duplicate district names, stale advisories, unavailable local data, or weather requests without a supported verified data source.
- **Security:** district is optional session context; avoid silently persisting it in the MVP.

### 5. Farmer asks a follow-up in the same conversation — MVP

- **Actor / start:** Farmer continues an active chat session.
- **Inputs:** new message and short-lived prior conversational context.
- **Processing:** resolve references such as “that crop” or “the scheme”; retain only the minimal context needed; retrieve again when a factual answer depends on it.
- **Database/RAG interaction:** **PROPOSED** conversation/session handling plus retrieval per relevant turn. No conversation persistence exists in the inspected code.
- **Response:** answer grounded in the earlier context, or ask a clarification where the reference is ambiguous.
- **Failure and edge cases:** stale or contradictory prior context, user changes district/crop, session expiration, or prompt-injection attempts embedded in chat history.
- **Security:** anonymous session identifiers must be non-sensitive, short-lived, and protected from cross-user access; do not persist personal data by default.

### 6. Administrator updates or reviews knowledge content — future after public-chat MVP

- **Actor / start:** Authorized content manager enters an authenticated administration workflow.
- **Inputs:** proposed content, source/reference, jurisdiction, effective/review date, category, and review decision.
- **Processing:** validate source/provenance; record review state; publish only approved public content; create a controlled indexing job after publication.
- **Database/RAG interaction:** **PROPOSED** content lifecycle, audit history, and controlled vector re-indexing. No content-management schema or UI is currently implemented.
- **Response:** clear published/rejected/pending status with an audit trail.
- **Failure and edge cases:** conflicting sources, stale policy, duplicate content, indexing failure, or unauthorized edit. Preserve prior approved content until a replacement is reviewed.
- **Security:** strong authentication, least privilege, audit logs, CSRF protection for a web UI, and separation from secrets/system settings.

### 7. Authenticated farmer accesses personalized information — future

- **Actor / start:** Farmer signs in and explicitly opts into a personalized service.
- **Inputs:** authenticated identity, consent, and only the minimum necessary profile/farm/application information.
- **Processing:** authorize access to the user's own records; combine private information only when needed with public knowledge; record consent and access events.
- **Database/RAG interaction:** **PROPOSED** private-data model and authorization checks. No confirmed farmer/private tables exist in the inspected project.
- **Response:** personalized result with an explanation of data used and controls to manage consent.
- **Failure and edge cases:** failed authentication, revoked consent, incomplete records, identity mismatch, or unavailable government integrations.
- **Security:** high-risk; require privacy policy, explicit consent, encryption, retention rules, access controls, and privacy-safe logging before implementation.

## MVP journeys and sequencing

The first working prototype should implement only journeys 1–5, using anonymous public sessions and verified public content. Crop, district, and season are optional question context rather than identity attributes. Journey 6 follows once the public knowledge model and review policy are established. Journey 7 is explicitly deferred.

## Security implications

- **CURRENT:** the existing backend permits all CORS origins and has no authentication; this is development-only posture, not an official product boundary.
- **PROPOSED:** public chat must apply request validation, rate limiting, abuse controls, safe logging, secrets isolation, and output/source safety rules.
- **PROPOSED:** administration must use dedicated authenticated roles, least privilege, review/audit trails, and separate operational permissions.
- **PROPOSED:** personalized features require explicit consent, purpose limitation, minimization, retention/deletion policy, and access controls before any private data is collected.

## Assumptions

1. ASK_KISAN serves Indian farmers and prioritizes agricultural and government-scheme information, consistent with the current terminal prompt.
2. Accuracy, source provenance, and clarity are more important than answering every question.
3. The MVP may operate anonymously; account creation is not a prerequisite for public information.
4. The production database must be preserved and any later development will use its confirmed schema rather than assumptions.
5. Weather-related answers are only in scope when a verified, current data source and locality context are available.

## Open questions

1. Which languages and accessibility requirements must the first farmer-facing interface support?
2. Which organization owns content review, and what sources count as authoritative for advisories and schemes?
3. What are the actual MySQL tables, relationships, and public/private-data boundaries?
4. Does `vector_embeddings` exist, and what source/provenance metadata and retrieval mechanism does it support?
5. Which geographic unit is required for MVP relevance: state, district, block, village, or all of these?
6. Which high-risk topics require a mandatory escalation notice or a refusal to provide detailed instructions?
7. Is an administrator workflow needed in the first release, or can initial content be managed through an approved operational process?
8. What retention period, privacy notice, and consent model are required before personalized services are considered?

## Recommended next design step

Perform an authenticated, read-only database metadata inspection using an already-approved MySQL-capable environment. It is the smallest step needed to turn the **UNCERTAIN** content, district, scheme, and vector assumptions in this document into a database-grounded MVP architecture.
