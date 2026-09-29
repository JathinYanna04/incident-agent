# Tasks

## 1. Schema

- [x] 1.1 Write `schema.sql` enabling `pgvector`, creating `incident_docs` (content, jsonb
      metadata, 768-dim embedding) and the `match_incident_docs` RPC function; verify by
      applying it via `supabase db push` and confirming no errors
- [x] 1.2 Track the schema as a Supabase migration under `supabase/migrations/`; verify with
      `supabase db push` reporting the migration applied

## 2. Seeding

- [x] 2.1 Write `requirements.txt` covering the full project's dependency floor; verify with
      `pip install -r requirements.txt` completing successfully
- [x] 2.2 Implement `seed_rag.py` embedding three starter runbooks (auth, database, payments)
      with `gemini-embedding-2-preview` at 768 dimensions and inserting them through the
      pooler; verify by running it and confirming "Success! Seeded 3 documents"
- [x] 2.3 Confirm retrieval works end-to-end by querying `match_incident_docs`-equivalent
      logic for a known symptom and checking the correct service's runbook is returned;
      verified via `search_remediation_runbooks` in the following change's smoke test
