# RAG and AI architecture

## Implemented embedding synchronization

`backend/app/scripts/generate_embeddings.py` is the single synchronization path for `vector_embeddings(id, source_table, source_id, content, content_hash, vector, embedding_model, created_at, updated_at)`. It uses `EMBEDDING_MODEL` (default `text-embedding-3-small`) and `OPENAI_API_KEY` from `backend/.env`; neither value is hard-coded.

`vector_embeddings` is a **derived search layer**, not the source of truth. The normal agricultural and scheme tables remain authoritative. The metadata migration adds nullable `content_hash`, `embedding_model`, and `updated_at` fields to the derived table without rebuilding it, deleting historical vectors, or changing an authoritative table.

The inspected production schema contains five searchable, populated source tables: `government_schemes`, `crops`, `crop_production_guides`, `crop_advisory`, and `scheme_faqs`. `crop_guides` is empty, so `crop_production_guides` is the current authoritative guide source. Reference tables (`advisory_categories`, `crop_stages`, `trigger_types`, `districts`, and `seasons`) are not embedded separately. Their resolved names and descriptions are included in each `crop_advisory` embedding.

Each source row maps to exactly one embedding key: `source_table` is the table name and `source_id` is that table's primary key. The script first reports source, already-embedded, and missing counts. It then checks the full `(source_table, source_id)` key before every action:

- no key: insert one row;
- matching key with unchanged content and a populated vector: skip;
- matching key whose generated content changed, or whose vector is empty: regenerate and update that existing row.

It never deletes embeddings, source records, or tables. Existing duplicate embedding keys are reported and never cause another insert. Use `--dry-run` for a no-write coverage report. The final report lists additions, skips, updates, failures, duplicate keys, and grouped final counts.

### Canonical content and incremental updates

The formatter functions in `generate_embeddings.py` are the only canonical-content implementation. The exact UTF-8 formatter output is used for both `SHA-256(content)` and the OpenAI embedding request; there is no second hash-only formatter. Synchronization therefore follows this rule:

- no `(source_table, source_id)` row: generate a vector and insert it with its hash and model;
- matching canonical `content_hash`: skip it;
- changed or absent hash: regenerate the vector and update the earliest existing row for that key, including `content`, `content_hash`, `embedding_model`, and `updated_at`.

`--backfill-metadata` computes hashes and model labels for current source-backed rows without generating or replacing vectors. It intentionally preserves orphaned rows—those with no longer-existing authoritative source record—with null metadata, because canonical content cannot be derived safely. `updated_at` is populated only when the synchronizer generates or replaces a vector; null is an intentional “predates update tracking” state for existing vectors.

The database does not yet have a unique `(source_table, source_id)` constraint. The synchronizer uses a MySQL named lock and application-level duplicate check to prevent new duplicates. Existing duplicates must be remediated under an explicitly approved policy before that constraint can be added.

## Retrieval

`app/rag/retrieval.py` embeds the question with the same configured model, reads populated JSON vectors, ranks them by cosine similarity, and returns source attribution. `test_chat.py` injects the attributed source content into the `gpt-4.1-mini` prompt. This keeps the existing MySQL JSON-vector storage format rather than introducing a second embedding store.

Run the checks below after synchronization:

```powershell
cd backend
python -m app.scripts.generate_embeddings --dry-run
python -m app.scripts.generate_embeddings
python -m app.scripts.test_retrieval
```

`test_retrieval.py` covers potato growing and disease questions, French-bean harvesting, maize caterpillars, turmeric waterlogging, e-NAM definition/registration, tomato lesions, rice irrigation, and cabbage caterpillars. It prints each retrieved source record and similarity score, so relevance can be reviewed against the stored natural-language content.

## Verified live synchronization (2026-08-24)

The initial inspection found 13 rows in `vector_embeddings`, all under `government_schemes`; 9 matched current source records. The synchronization added the 169 missing source keys (12 crops, 12 production guides, 120 advisories, and 25 FAQs) and refreshed 9 changed government-scheme records in place. A final no-write run reports 178 current source records, 178 matching embeddings, zero missing records, zero required updates, and zero failed embeddings.

Final stored rows by `source_table` are: 120 `crop_advisory`, 12 `crop_production_guides`, 12 `crops`, 13 `government_schemes`, and 28 `scheme_faqs`. Four legacy scheme rows no longer match a current scheme source key; three duplicate `scheme_faqs` keys (23, 24, and 25) were detected and retained because the migration must not delete existing embeddings. Retrieval deduplicates by `(source_table, source_id)`, and the synchronizer holds a MySQL named lock to prevent a concurrent run from adding further duplicates.

The metadata backfill recorded valid 64-character SHA-256 hashes and `text-embedding-3-small` for 181 source-backed rows. The four preserved government-scheme orphans (`vector_embeddings` IDs 2, 8, 12, and 13) retain null hash/model metadata. All 185 stored vectors are populated 1,536-dimensional JSON arrays. A post-backfill dry run reports 178 current source rows: 0 inserts, 0 updates, and 178 skips.

| Retrieval question | Highest relevant record | Why it is relevant |
| --- | --- | --- |
| How do I grow potato in Darjeeling? | `crop_advisory:61` | Potato, Darjeeling, pre-sowing cultural-practice advice. |
| Potato leaves with dark spots | `crop_advisory:68` | Potato disease-management advisory. |
| When to harvest French beans? | `crop_advisory:60` | French Bean harvest-stage advisory. |
| Maize caterpillars in the whorl | `crop_advisory:77` | Maize vegetative-stage pest-management advisory. |
| Turmeric waterlogging | `crop_production_guides:4` | Turmeric guide specifies drainage and irrigation context. |
| What is e-NAM? | `scheme_faqs:11` | e-NAM definition FAQ. |
| Register on e-NAM | `scheme_faqs:12` | e-NAM registration FAQ. |
| Tomato dark lesions | `crop_advisory:129` | Tomato disease-management advisory. |
| Rice irrigation requirements | `crop_production_guides:8` | Rice irrigation guidance. |
| Cabbage caterpillars | `crop_advisory:107` | Cabbage pest-management advisory. |

## Limitation

The current corpus is small enough for application-side cosine ranking. If the corpus grows substantially, preserve the `(source_table, source_id)` mapping and migrate only the ranking implementation to an indexed vector capability.

