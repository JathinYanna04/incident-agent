# Proposal

## Why

With a knowledge base in place, the next step is an agent that can actually use it: check a
service's health and search runbooks to investigate an incident. This change deliberately
excludes escalation — it builds only the safe, read-only investigation path first, so the
human-in-the-loop approval gate (next change) can be added and reviewed in isolation.

## What Changes

- Add `agent.py` with a LangGraph agent: an `AgentState`, a `call_model` node with a system
  prompt directing it to check health first and then search runbooks, and two safe tools
  (`query_service_health`, `search_remediation_runbooks`).
- Add a Postgres connection pool (`psycopg_pool.ConnectionPool`) configured for the Supabase
  transaction pooler.
- Add a `PostgresSaver` checkpointer so conversation state persists per `thread_id`.
- Add a text-normalization helper so list-structured model output is flattened to plain text.

## Capabilities

### New Capabilities
- `triage-agent`: The core investigation loop — health check, then runbook search, with
  state persisted per incident thread.

### Modified Capabilities
(none)

## Impact

- **New code**: `agent.py` (state, tools, graph, checkpointer wiring).
- **Depends on**: `knowledge-base` (for `search_remediation_runbooks`).
- **Rollback**: remove `agent.py`; no other capability depends on it yet.
