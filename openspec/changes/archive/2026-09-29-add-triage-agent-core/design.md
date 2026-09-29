# Design

## Context

Builds directly on the `knowledge-base` capability's `match_incident_docs`-equivalent
retrieval. See `proposal.md - Why` for why escalation is deliberately excluded here.

## Goals / Non-Goals

**Goals:**
- A working investigate-only agent that can be manually and automatically tested before any
  side-effecting action exists in the codebase.
- Durable state from the start, so later changes (HITL, API) build on a persistence model
  that is already proven.

**Non-Goals:**
- Any tool with a real-world side effect — deferred entirely to `add-hitl-escalation`.
- A REST or UI surface — deferred to `add-api-and-ui`.

## Decisions

**LangGraph `StateGraph` with a single `agent` node looping through a `safe_tools` `ToolNode`.**
Chosen over a hand-rolled loop because LangGraph's `ToolNode` and conditional-edge routing
integrate directly with the `PostgresSaver` checkpointer needed for durable state, and because
the same graph shape extends cleanly to add a `sensitive_tools` branch in the next change
without restructuring.

**`psycopg_pool.ConnectionPool` with `prepare_threshold=None`.** Required because the Supabase
transaction pooler does not support session-level prepared statements; without this setting,
queries intermittently fail with "prepared statement already exists" errors under the pooler.

**A dedicated `extract_text` normalization step after each model call.** Some Gemini responses
return content as a list of blocks rather than a plain string; normalizing immediately after
the model call (rather than at every consumer of the message) keeps all downstream code
(API responses, UI display) simple.

## Risks / Trade-offs

- **[Risk]** The mocked `query_service_health` tool returns canned data for three hardcoded
  services. → **Mitigation**: acceptable for this stage; swapping in a real health-check API
  later only touches this one tool function, not the graph shape or state model.
- **[Trade-off]** Checkpointing every state transition to Postgres adds latency per turn
  compared to in-memory state. Accepted because durability across restarts is a hard
  requirement from the seed idea.
