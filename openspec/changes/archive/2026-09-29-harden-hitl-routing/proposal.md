# Proposal

## Why

Comparing `openspec/specs/hitl-approval/spec.md` against the actual `route_tools`
implementation revealed a real safety gap: routing only inspected the **first** tool call in a
model turn (`last_message.tool_calls[0]`). If the model ever returns multiple tool calls in one
turn — e.g. a health check bundled with an escalation — and the sensitive call is not first,
that call would not be routed through the approval-gated branch as intended. This was flagged
as an explicit known risk in `add-hitl-escalation`'s design.md and is closed here.

## What Changes

- **BREAKING**: `route_tools` now routes the entire turn to the gated `sensitive_tools` branch
  if **any** tool call in it is sensitive, not just the first.
- The `sensitive_tools` node is now a `ToolNode(all_tools)` (not just the sensitive tools), so
  it can execute a mixed batch of safe + sensitive calls together once approved.
- `POST /chat`'s `AWAITING_APPROVAL` response now returns `pending_actions` (a list) instead of
  a single `pending_action`/`parameters` pair, since a paused turn may contain more than one
  sensitive call.
- Rejection now sends a `ToolMessage` response for **every** pending tool call in the paused
  turn (required by LangGraph before the turn can resume), not only the sensitive one.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `hitl-approval`: the approval-gate requirement now covers any sensitive call within a turn,
  not just the first.
- `triage-api`: the awaiting-approval response shape changes from a single pending action to a
  list of pending actions.

## Impact

- **Changed code**: `route_tools` and the `sensitive_tools` node in `agent.py`; the
  `AWAITING_APPROVAL` response shape and rejection logic in `app.py` (REST handlers and Gradio
  callbacks).
- **BREAKING**: any client relying on the old singular `pending_action`/`parameters` fields
  from `/chat` must update to read the `pending_actions` list instead.
- **Rollback**: revert `route_tools` to the `tool_calls[0]` check and the response shape to
  singular; re-introduces the known gap this change closes.
