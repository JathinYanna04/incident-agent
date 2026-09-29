# Design

## Context

First change in the project — no prior code to integrate with. See `proposal.md - Why`.

## Goals / Non-Goals

**Goals:**
- Make the runbook store queryable by meaning, not just exact keywords.
- Keep the whole stack on free tiers.

**Non-Goals:**
- Runbook authoring/editing UI — runbooks are seeded from a fixed list for this change.
- Real-time runbook ingestion from an external wiki — out of scope until a later change.

## Decisions

**Supabase Postgres + `pgvector` over a dedicated vector database.** Keeps infrastructure to a
single connection string and a single free-tier provider, and lets the same database later
also hold LangGraph checkpoints (decided in `add-triage-agent-core`). Alternative considered: a
hosted vector DB free tier — rejected to avoid a second provider and a second set of credentials.

**Gemini embeddings at 768 dimensions (Matryoshka reduction) over the model's native size.**
Keeps the vector column a fixed, moderate size and matches common `pgvector` index guidance.

**Transaction pooler (port 6543) over a direct connection.** Render's free web service
instances get recycled/ephemeral connections; the pooler tolerates that connection churn.
Requires `prepare_threshold=None` on the psycopg pool, since the transaction pooler does not
support session-level prepared statements.

## Risks / Trade-offs

- **[Risk]** Free-tier embedding/API rate limits could throttle seeding of a much larger
  runbook set. → **Mitigation**: acceptable at the current starter-set scale (3 runbooks).
- **[Risk]** Idempotent seeding is not enforced by a database constraint in this change (no
  unique constraint on content), only by seed-script discipline. → **Mitigation**: documented
  here as a known gap; acceptable for a fixed, small starter set where the script is run
  manually and rarely.
