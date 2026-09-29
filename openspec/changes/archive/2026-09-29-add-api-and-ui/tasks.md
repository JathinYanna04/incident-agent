# Tasks

## 1. REST API

- [x] 1.1 Implement `POST /chat` returning `COMPLETED` or `AWAITING_APPROVAL`; verify with a
      non-escalating and an escalating incident against a running instance
- [x] 1.2 Implement `POST /approve` returning `RESOLVED` or `REJECTED_AND_RESUMED`, and a 400
      when nothing is pending; verify all three outcomes against a running instance

## 2. Gradio UI

- [x] 2.1 Build the Blocks layout (thread ID, incident description, trigger button, rejection
      reason, approve/reject buttons, workflow-state label, response markdown); verify by
      loading the UI and confirming all controls render
- [x] 2.2 Wire `run_triage` and `handle_decision` callbacks to the same agent executor used by
      the REST handlers; verify a full trigger -> approve cycle in the browser
- [x] 2.3 Handle missing thread ID / incident description in the UI callbacks with a clear
      message instead of calling the agent; verify by submitting with an empty thread ID

## 3. Combined App

- [x] 3.1 Mount the Gradio UI onto the FastAPI app via `gr.mount_gradio_app`, exposing a single
      `app` object; verify `uvicorn app:app` serves both `/` (UI) and `/chat` (API) from one
      process
