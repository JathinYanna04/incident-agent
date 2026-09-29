# Design

## Context

Deploys the app built in `add-api-and-ui`. See `proposal.md - Why`.

## Goals / Non-Goals

**Goals:**
- Zero-cost, no-credit-card hosting.
- No special handling required for cold starts beyond what the checkpointer already provides.

**Non-Goals:**
- High availability / multiple regions / autoscaling — a single free instance is sufficient.
- CI/CD pipeline beyond Render's built-in auto-deploy-on-push.

## Decisions

**Render free Web Service over a serverless function platform.** A single free web service
matches "one process serves UI + API" from the previous change, and Render's free tier needs
no credit card, unlike some serverless free tiers that require one for verification.

**`GET /healthz` is a static 200, not a DB/LLM ping.** A health check that calls the database or
Gemini would make Render's health-check polling count against free-tier rate limits and could
report the service unhealthy due to a transient Gemini hiccup rather than an actual service
failure. Liveness (is the process up) is a different concern from readiness (can it reach
Postgres/Gemini), and only liveness is needed for Render's health check.

**Rely on the existing `PostgresSaver` checkpointer for cold-start recovery rather than adding
new deployment-specific state handling.** Because state already lives in Supabase Postgres, not
in-process memory, a Render cold start is indistinguishable from any other process restart
already covered by `hitl-approval`'s "pause survives restart" requirement — no new mechanism is
needed, only verification that it holds in the deployed environment too.

## Risks / Trade-offs

- **[Risk]** Free Render instances spin down after ~15 minutes idle; the first request after
  spin-down takes 30-60 seconds. → **Mitigation**: documented in the README as expected
  behavior; state safety does not depend on the instance staying warm.
- **[Risk]** Environment variables are visible to anyone with Render dashboard access to the
  service. → **Mitigation**: acceptable for this single-owner deployment; noted as a constraint.
