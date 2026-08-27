# Target architecture

## MVP flow

Farmer-facing frontend → public chat API → input/context validation → retrieval over approved public content → grounded model response with source attribution → anonymous session response.

The existing MySQL database remains authoritative. Retrieval design must follow verified schema rather than assumed tables. Crop, district, and season are optional session context; they are not identity data in the MVP.

## Deferred boundaries

Administration should be a separately authenticated content workflow. Personalized farmer services require a distinct private-data, consent, and authorization design.

The public query API, retrieval, source identifiers, anonymous session response, and frontend are **CURRENT / IMPLEMENTED**. Optional crop/district/season context, persisted follow-ups, and human-readable source details remain proposed. Significant technology choices are recorded in ADRs.
