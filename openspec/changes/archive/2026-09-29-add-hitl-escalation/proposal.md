# Proposal

## Why

The core agent can investigate but has no way to act on a finding that needs human
intervention. Escalating (paging on-call, filing a ticket) has real cost if wrong, so this
capability must never execute automatically — it needs a structural approval gate, not just an
instruction to the model.

## What Changes

- Add an `escalate_ticket` tool, marked sensitive, separate from the existing safe tools.
- Split tools into `safe_tools` and `sensitive_tools`, with routing sending escalation calls to
  the sensitive branch.
- Compile the graph with `interrupt_before=["sensitive_tools"]` so execution halts before an
  escalation runs, pausing for human approval.
- Support resuming a paused thread on approval (executes the escalation) or rejection (injects
  the rejection reason as a tool result and lets the agent continue reasoning without escalating).

## Capabilities

### New Capabilities
- `hitl-approval`: Human-in-the-loop gate that requires explicit approval before any
  sensitive tool executes, and supports approval, rejection, and resuming from a paused state.

### Modified Capabilities
(none — `triage-agent`'s existing requirements are unchanged; this adds a new capability
alongside it)

## Impact

- **New code**: `escalate_ticket` tool, `sensitive_tools` node, and `interrupt_before` config
  in `agent.py`.
- **Depends on**: `triage-agent` (extends its graph with the sensitive branch).
- **Rollback**: remove the `sensitive_tools` node and `interrupt_before`; the agent falls back
  to investigate-only behavior from `add-triage-agent-core`.
