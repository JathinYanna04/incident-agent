# Design

## Context

This is a new project with no existing services or specs to integrate with.
The primary constraint is cost: the entire stack must run on free tiers with
no credit card requirement, which drives most of the technology choices below.
See `proposal.md - Why` for the motivating problem.

## Goals / Non-Goals

**Goals:**
- Run entirely on free-tier infrastructure (no paid plan, no credit card).
- Make the human-in-the-loop gate structural (enforced by the agent graph
  itself), not a convention the LLM is merely instructed to follow.
- Survive process restarts without losing an in-progress or paused incident.

**Non-Goals:**
- Multi-tenant auth/authorization for the API or UI — this is a single-team
  internal tool; anyone who can reach the URL can trigger and approve triage.
- Real integration with a live service-health system or a real ticketing
  system — `query_service_health` and `escalate_ticket` are mocked/simulated
  for this change, matching the reference guide's scope.
- Horizontal scaling / high availability — a single free Render instance is
  sufficient for this change.

## Decisions

**LangGraph for orchestration, with `interrupt_before` as the approval gate.**
Rather than prompting the model to "ask before escalating" (unenforceable —
an LLM can ignore instructions), tools are partitioned into `safe_tools` and
`sensitive_tools` at the graph level, and the compiled graph is given
`interrupt_before=["sensitive_tools"]`. This makes the pause a property of the
state machine, not of the model's behavior. Alternative considered: a
single tool list with a "confirm" flag checked in application code — rejected
because it relies on the LLM/tool code to self-report correctly rather than
the graph structurally refusing to proceed.

**Postgres (via Supabase) for both checkpointing and the vector store.**
Using one database for both `langgraph-checkpoint-postgres` and `pgvector`
avoids running/paying for two separate managed stores. The Supabase
transaction pooler (port 6543) is used specifically because Render's free
instances get ephemeral, frequently-recycled connections, and the pooler
handles that connection churn better than a direct Postgres connection would.
Alternative considered: a dedicated vector DB (e.g. a hosted Pinecone free
tier) — rejected to keep infrastructure to a single provider and connection
string.

**Gemini via Google AI Studio for both reasoning and embeddings.**
Chosen specifically because Google AI Studio's developer tier has no cost and
no card requirement, unlike most alternatives. `gemini-embedding-2-preview` is
configured with `output_dimensionality=768` (Matryoshka reduction) to keep
the embedding column a manageable fixed size in Postgres.

**Gradio mounted onto FastAPI as a single ASGI app, on Render's free web
service.** One process serves both the human-facing UI and the machine-facing
REST API, so only one free service is needed instead of two. Alternative
considered: a separate static frontend calling the API — rejected as
unnecessary complexity for this scope.

## Risks / Trade-offs

- **[Risk]** Render's free instance spins down after ~15 minutes idle, so the
  first request after idling is slow (30-60s) and could be mistaken for a
  hang. → **Mitigation**: documented in README; state is safe either way
  because it lives in Postgres, not in-process memory.
- **[Risk]** The mocked `query_service_health` and `escalate_ticket` tools
  return canned data rather than calling real systems, so this is a
  reference/demo implementation, not production-ready incident response.
  → **Mitigation**: tool implementations are isolated functions in `agent.py`;
  swapping in real API calls later does not require changing the graph,
  the approval gate, or the specs.
- **[Risk]** Storing `GEMINI_API_KEY` and `DATABASE_URL` as plain Render
  environment variables means anyone with dashboard access can read them.
  → **Mitigation**: acceptable for this single-user/demo scope; noted as a
  constraint rather than solved here.
- **[Trade-off]** Using one Postgres instance for both checkpoints and vectors
  is simpler to operate but couples their availability and scaling together.
  Acceptable at this scale; would need to be revisited if either workload
  grew significantly.
