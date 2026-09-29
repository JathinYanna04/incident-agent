# Design

## Context

Closes the known gap recorded in `add-hitl-escalation/design.md`'s Risks section: routing
only inspected `tool_calls[0]`. See `proposal.md - Why`.

## Goals / Non-Goals

**Goals:**
- Close the approval-bypass gap for any number of tool calls in a single turn.
- Keep the fix contained to routing and response shape — no change to the underlying
  `interrupt_before` mechanism, which is already correct.

**Non-Goals:**
- Splitting a mixed turn into two separate turns (one auto-run safe, one gated) — rejected as
  unnecessary complexity; routing the whole turn through the gate is simpler and still correct,
  at the cost of a safe call in the same turn also waiting for the approval decision.

## Decisions

**Route on "any sensitive call present" rather than "first call is sensitive".** Direct fix
for the identified gap; `any(tc["name"] in SENSITIVE_TOOL_NAMES for tc in tool_calls)` is
correct regardless of call order or count.

**`sensitive_tools` node becomes `ToolNode(all_tools)` instead of `ToolNode(sensitive_tools)`.**
Once a turn is routed to the gated branch because it contains a sensitive call, that branch
must be able to execute every call in the turn on approval — including any safe calls bundled
alongside the sensitive one. Using `ToolNode(sensitive_tools)` alone would raise an error on an
unrecognized (safe) tool name in the same turn.

**Response shape changes from singular to a list, as a breaking change rather than a
backward-compatible addition.** A singular field alongside a new list field would let clients
silently keep reading only the first action and reintroduce the same class of bug one layer up,
in client code. Since this project has one client (the bundled Gradio UI) and one documented
consumer (the REST API docs), breaking the shape now is safer than preserving a misleading
singular field.

## Risks / Trade-offs

- **[Risk]** This is a breaking API change for `/chat`'s `AWAITING_APPROVAL` response.
  → **Mitigation**: the only consumer in this repository (the Gradio UI) is updated in the same
  change; documented as **BREAKING** in the proposal for any external consumer.
- **[Trade-off]** Bundling a safe call into the same gated turn as a sensitive call means the
  safe call's result is also delayed until a human acts on the sensitive one, even though the
  safe call itself needed no approval. Accepted: correctness (never auto-running a sensitive
  call) takes priority over that minor latency cost.
