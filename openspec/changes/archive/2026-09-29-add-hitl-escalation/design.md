# Design

## Context

Extends the `triage-agent` graph from `add-triage-agent-core` with a second, gated branch.
See `proposal.md - Why` for the motivating safety requirement.

## Goals / Non-Goals

**Goals:**
- Make the approval pause a property of the compiled graph, not of prompt instructions the
  model could ignore.
- Preserve the ability to resume correctly after a restart, since the checkpointer already
  persists state (from `add-triage-agent-core`).

**Non-Goals:**
- Authentication/authorization on who may approve — anyone reaching the approval mechanism can
  approve or reject (acceptable for this project's single-team scope; noted as a future change).
- Handling multiple sensitive tool calls within a single model turn — this change assumes one
  sensitive call at a time, matching the current single-tool-per-turn behavior observed from
  the model. (Revisited in `harden-hitl-routing`.)

## Decisions

**`interrupt_before=["sensitive_tools"]` at graph-compile time, not an in-tool check.**
This is the core safety decision: the graph itself refuses to run the `sensitive_tools` node
until the caller explicitly resumes it. An in-tool "are you sure?" check would still execute
inside the same turn and could be bypassed by any code path that calls the tool function
directly. Alternative considered and rejected for that reason.

**Rejection is modeled as a `ToolMessage` injected via `update_state(..., as_node=
"sensitive_tools")`, not a special-cased short-circuit.** This keeps rejection handling inside
the normal LangGraph message flow — the agent sees the rejection exactly as it would see any
other tool result, and can reason about it (e.g. propose an alternative) using its normal
reasoning path, rather than a bespoke "rejected" code branch bypassing the model.

## Risks / Trade-offs

- **[Risk]** Only the first tool call in a model turn is inspected when deciding whether to
  route to `sensitive_tools`. If the model ever returns multiple tool calls in one turn with a
  sensitive call not in the first position, it could bypass the approval gate. → **Mitigation**:
  not fully closed in this change; tracked explicitly as a known gap to be hardened in a later
  change once real routing behavior can be observed and tested against.
- **[Risk]** No audit trail beyond the checkpointed message history — there is no separate log
  of who approved what and when. → **Mitigation**: acceptable for the current scope; the
  Postgres checkpoint history itself is queryable if an audit trail is later required.
