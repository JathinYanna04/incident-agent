# Proposal

## Why

On-call engineers currently triage incidents manually: check service health, search
runbooks/wikis for the right remediation, and decide whether to escalate — all under
time pressure. This is slow and inconsistent, and fully autonomous remediation is too
risky because a wrong automated action (e.g. paging the wrong team, filing a bad
ticket) has real cost. We need an agent that automates the investigation and
recommendation steps but keeps a human in the loop before any action with real-world
side effects, with state that survives process restarts so a paused incident is never
silently lost.

## What Changes

- Add an agent that inspects service health, searches a vector-indexed runbook
  knowledge base, and decides whether to escalate an incident.
- Add a retrieval-augmented generation (RAG) knowledge base of remediation runbooks,
  embedded and stored in Postgres via `pgvector`, queried by semantic similarity.
- Add a human-in-the-loop (HITL) approval gate: any tool with real-world side effects
  (escalating a ticket) halts the agent and requires explicit human approval or
  rejection before it runs.
- Add durable, resumable agent state: conversation and tool-call history are
  checkpointed to Postgres per `thread_id`, so an incident paused awaiting approval
  survives a server restart and resumes from the exact same point.
- Add a REST API (`/chat`, `/approve`) and a Gradio web UI for triggering triage,
  inspecting pending approvals, and approving/rejecting them.

## Capabilities

### New Capabilities
- `incident-health-check`: Look up the current health/status of a named backend
  service on demand.
- `runbook-retrieval`: Semantic (vector) search over a knowledge base of incident
  remediation runbooks, returning the most relevant runbook(s) for a query.
- `incident-escalation-approval`: Human-in-the-loop gate that proposes escalating an
  incident to on-call, halts for explicit approval or rejection, and only pages
  on-call once approved.
- `incident-triage-agent`: The orchestrating agent loop that combines health checks
  and runbook retrieval to reason about an incident, decides when escalation is
  warranted, and exposes the whole flow (start, resume, approve, reject) via a REST
  API and a UI, with all state persisted so it survives restarts.

### Modified Capabilities
(none — this is a new project with no pre-existing specs)

## Impact

- **New code**: `agent.py` (LangGraph state machine, tools, checkpointing),
  `app.py` (FastAPI + Gradio), `seed_rag.py` (knowledge base seeding), `schema.sql` /
  `supabase/migrations/` (pgvector schema).
- **New external dependencies**: Google AI Studio (Gemini reasoning + embedding
  models), Supabase Postgres with the `pgvector` extension, Render (hosting).
- **APIs added**: `POST /chat`, `POST /approve` (REST); a Gradio UI at `/`.
- **Data**: new `incident_docs` table and `match_incident_docs` RPC function in
  Postgres; a new LangGraph checkpoint schema managed by `PostgresSaver`.
