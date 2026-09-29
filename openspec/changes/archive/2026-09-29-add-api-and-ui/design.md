# Design

## Context

Wraps the already-working `triage-agent` + `hitl-approval` graph from the previous two
changes with an HTTP and UI layer. See `proposal.md - Why`.

## Goals / Non-Goals

**Goals:**
- Serve both the REST API and the UI from a single process/port, to minimize free-tier
  infrastructure.
- Keep the REST handlers and the UI callbacks logically consistent (same status vocabulary:
  `COMPLETED`/`AWAITING_APPROVAL`/`RESOLVED`/`REJECTED_AND_RESUMED`).

**Non-Goals:**
- Authentication on either surface — deferred; anyone with the URL can trigger and approve.
- Streaming/incremental responses — both surfaces wait for a full agent turn before responding.

## Decisions

**Gradio Blocks mounted onto FastAPI via `gr.mount_gradio_app`, exposing one ASGI `app`
object.** Chosen so Render's start command (`uvicorn app:app`) serves both surfaces from one
free web service, instead of needing two separate deployments.

**REST and UI each call `get_agent_app()`'s compiled graph directly rather than the UI calling
the REST API internally.** Both are thin adapters over the same `agent_executor`; going
UI-over-HTTP would add latency and a failure mode (self-HTTP-call) with no benefit at this
scale.

## Risks / Trade-offs

- **[Risk]** No auth means anyone who can reach the deployed URL can trigger triage or approve/
  reject any thread's pending escalation. → **Mitigation**: acceptable for a single-team demo
  scope; flagged in the seed idea's follow-up ideas as a candidate for a future change
  (`add-approve-endpoint-auth`).
- **[Trade-off]** A single process serving both the UI and the API means a UI-side bug could
  in principle affect API availability. Accepted for the simplicity gain at this scale.
