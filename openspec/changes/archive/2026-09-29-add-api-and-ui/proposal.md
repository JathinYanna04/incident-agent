# Proposal

## Why

The agent and its approval gate are only usable from a Python REPL today. Engineers need a
way to trigger triage and act on pending approvals without writing code: a REST API for
programmatic/automation use, and a web UI for interactive use.

## What Changes

- Add `POST /chat` (submit an incident message for a thread; returns `COMPLETED` or
  `AWAITING_APPROVAL` with the pending action's details).
- Add `POST /approve` (approve or reject a pending action for a thread; returns `RESOLVED` or
  `REJECTED_AND_RESUMED`, or a 400 if nothing is pending).
- Add a Gradio Blocks UI (thread ID + incident description inputs, trigger button, approve/
  reject controls with an optional rejection reason, workflow-state and response display).
- Mount the Gradio UI onto the FastAPI app as a single ASGI object so both are served by one
  process.

## Capabilities

### New Capabilities
- `triage-api`: REST endpoints for submitting incidents and resolving pending approvals.
- `triage-ui`: Interactive web UI over the same agent and approval flow.

### Modified Capabilities
(none — this exposes `triage-agent` and `hitl-approval`, it does not change their behavior)

## Impact

- **New code**: `app.py` (FastAPI routes, Gradio Blocks layout, `gr.mount_gradio_app`).
- **Depends on**: `triage-agent`, `hitl-approval`.
- **Rollback**: remove `app.py`; the agent remains usable programmatically via `agent.py`.
