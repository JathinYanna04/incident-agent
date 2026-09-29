# Tasks

## 1. Database & Knowledge Base

- [x] 1.1 Enable `pgvector` and create the `incident_docs` table plus the
      `match_incident_docs` RPC in Supabase Postgres; verify via
      `supabase db push` reporting the migration applied successfully
- [x] 1.2 Implement `seed_rag.py` to embed a starter set of runbooks with
      `gemini-embedding-2-preview` (768-dim) and insert them into
      `incident_docs`; verify by running it and confirming
      "Success! Seeded 3 documents into Supabase pgvector."

## 2. Incident Health Check (`incident-health-check`)

- [x] 2.1 Implement `query_service_health` as a case-insensitive lookup tool
      over a small set of known services; verify by calling it with
      `"auth"`, `"Auth"`, and an unknown name and confirming degraded,
      healthy, and "not found" responses respectively

## 3. Runbook Retrieval (`runbook-retrieval`)

- [x] 3.1 Implement `search_remediation_runbooks` to embed the query with
      `RETRIEVAL_QUERY` task type and run a cosine-similarity search
      (`<=>` operator) against `incident_docs`, limited to top 2 results;
      verify by querying with a known incident symptom and confirming the
      matching runbook's service tag is returned
- [x] 3.2 Handle the empty-knowledge-base case by returning a clear
      "No relevant runbooks found." message; verified by code inspection
      of the `if not rows` branch (empty-DB path not separately re-tested
      after seeding)

## 4. Escalation Approval Gate (`incident-escalation-approval`)

- [x] 4.1 Implement `escalate_ticket` as a sensitive tool, and split all
      tools into `safe_tools` (health check, runbook search) vs.
      `sensitive_tools` (escalation) in `agent.py`
- [x] 4.2 Compile the LangGraph workflow with
      `interrupt_before=["sensitive_tools"]` so escalation halts before
      executing; verify by submitting an incident requiring escalation and
      confirming `get_state(config).next == ("sensitive_tools",)`
- [x] 4.3 Implement the `/approve` endpoint's approval path: resume the
      graph with `invoke(None, config)` and return the resulting message;
      verified end-to-end against the deployed service (`status: RESOLVED`,
      ticket created, on-call paged)
- [x] 4.4 Implement the `/approve` endpoint's rejection path: inject a
      `ToolMessage` with the rejection reason via `update_state(...,
      as_node="sensitive_tools")`, then resume; verify by rejecting a
      pending escalation with a reason and confirming the agent's next
      response references it instead of a ticket confirmation
- [x] 4.5 Return a 400 error from `/approve` when no action is pending for
      the given thread; verified by code inspection of the
      `if not snapshot.next or "sensitive_tools" not in snapshot.next`
      guard in `app.py`

## 5. Triage Agent Orchestration (`incident-triage-agent`)

- [x] 5.1 Implement the `call_model` node with a system prompt directing
      the agent to check health, search runbooks, then decide on
      escalation, and wire routing via `route_tools`; verify with an
      end-to-end local run showing health check -> runbook search ->
      escalation proposal in sequence
- [x] 5.2 Configure `PostgresSaver` checkpointing keyed by `thread_id` so
      state persists per incident; verify by resuming a paused thread in a
      fresh process and confirming it resolves using the prior context
- [x] 5.3 Implement `POST /chat` returning `COMPLETED` or
      `AWAITING_APPROVAL` (with pending action name and parameters);
      verified against the deployed service for both a non-escalating and
      an escalating incident
- [x] 5.4 Implement `POST /approve` returning `RESOLVED` or
      `REJECTED_AND_RESUMED`; verified against the deployed service
- [x] 5.5 Build the Gradio UI (thread ID + incident description inputs,
      trigger button, approve/reject controls, workflow state and
      response display) mounted onto the FastAPI app via
      `gr.mount_gradio_app`; verified manually by triggering triage and
      approving an escalation in the browser

## 6. Deployment

- [x] 6.1 Push the project to a GitHub repository with `.env` excluded via
      `.gitignore`; verified `.env` absent from `git status` before push
- [x] 6.2 Create a Render free web service from the repo with build command
      `pip install -r requirements.txt` and start command
      `uvicorn app:app --host 0.0.0.0 --port $PORT`, with `GEMINI_API_KEY`,
      `DATABASE_URL`, and `PYTHON_VERSION` set; verify the deploy reaches
      `status: live`
- [x] 6.3 Smoke-test the live deployment's `/`, `/docs`, `/chat`, and
      `/approve` endpoints; verified all four returning expected
      status/content against `https://incident-agent-jkm3.onrender.com`
