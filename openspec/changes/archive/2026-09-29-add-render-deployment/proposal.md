# Proposal

## Why

The agent, API, and UI work locally but are not reachable by anyone else. This change makes
the service reachable on the public internet, on a free tier, in a way that survives the
platform's cold-start/spin-down behavior without losing state.

## What Changes

- Add a `GET /healthz` endpoint that returns 200 without calling Gemini or the database, for
  platform health checks.
- Document deployment to Render as a free web service (build command, start command, required
  environment variables, Python version).
- Document free-tier behavior (spin-down after ~15 minutes idle, 30-60s cold start) and why it
  is safe given the Postgres-backed checkpointer.
- Verify `.env` is never committed to the repository.

## Capabilities

### New Capabilities
- `deployment`: The service is reachable over HTTPS on a free hosting tier, binds to the
  platform-provided port, keeps secrets out of source control, and survives cold starts
  without losing paused-incident state.

### Modified Capabilities
(none)

## Impact

- **New code**: `GET /healthz` route in `app.py`.
- **New docs**: deployment steps and free-tier notes in `README.md`.
- **Depends on**: `triage-api` (the app being deployed), `hitl-approval` (state that must
  survive cold starts).
- **Rollback**: delete the Render service; local development is unaffected.
