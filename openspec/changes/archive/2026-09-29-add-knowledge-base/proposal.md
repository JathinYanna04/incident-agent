# Proposal

## Why

The triage agent needs a place to look up how past incidents were remediated. Without a
searchable knowledge base, every incident would require an engineer to manually recall or find
the right runbook. This change builds that knowledge base first, independently of the agent, so
later changes can rely on it.

## What Changes

- Add a Postgres schema (`incident_docs` table + `match_incident_docs` RPC) with `pgvector`
  enabled, storing runbook content alongside a 768-dimension embedding and JSON metadata.
- Add a seed script that embeds a starter set of runbooks (auth, database, payments) with
  Gemini embeddings and inserts them via the Supabase transaction pooler.
- Add `requirements.txt` for the whole project's dependency floor.

## Capabilities

### New Capabilities
- `knowledge-base`: Storage and semantic retrieval of incident remediation runbooks.

### Modified Capabilities
(none — first change in the project)

## Impact

- **New code**: `schema.sql`, `supabase/migrations/*.sql`, `seed_rag.py`, `requirements.txt`.
- **New external dependency**: Supabase Postgres with `pgvector`; Google AI Studio embeddings.
- **Rollback**: drop the `incident_docs` table and `match_incident_docs` function; no other
  capability depends on this schema yet.
