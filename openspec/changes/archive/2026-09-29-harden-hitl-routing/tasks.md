# Tasks

## 1. Routing Fix

- [x] 1.1 Add `SENSITIVE_TOOL_NAMES` and change `route_tools` to check `any(...)` across all
      tool calls instead of `tool_calls[0]`; verify by code inspection and by re-running the
      existing single-sensitive-call smoke test to confirm no regression
- [x] 1.2 Change the `sensitive_tools` node to `ToolNode(all_tools)` so a mixed batch can be
      executed together on approval; verify the graph still compiles and the existing
      approval smoke test still resolves correctly

## 2. API & UI Updates

- [x] 2.1 Add `pending_sensitive_calls()` and `reject_pending_calls()` helpers in `app.py`;
      update `/chat` to return `pending_actions` (a list) and `/approve`'s rejection path to
      answer every pending tool call; verify via `TestClient` against a `/chat` +
      `/approve` (reject) round trip
- [x] 2.2 Update the Gradio `run_triage` and `handle_decision` functions to use the same
      helpers; verify by inspecting the rendered Markdown lists every pending action

## 3. Regression Verification

- [x] 3.1 Re-run the full local smoke test (health check -> runbook search -> escalation
      proposal -> approve) end-to-end and confirm identical behavior to before this change
      for the single-sensitive-call case; verified via `agent.py`'s compiled graph directly
- [x] 3.2 Verify a reject-with-reason round trip through the REST API returns
      `REJECTED_AND_RESUMED` with a response reflecting the supplied reason; verified via
      `TestClient`
