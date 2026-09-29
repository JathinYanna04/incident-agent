# Tasks

## 1. Connection & State

- [x] 1.1 Configure `psycopg_pool.ConnectionPool` against `DATABASE_URL` with
      `prepare_threshold=None` and `autocommit=True`; verify by connecting successfully
      through the Supabase pooler
- [x] 1.2 Define `AgentState` (messages with `add_messages` reducer); verify by inspecting
      that tool and AI messages accumulate correctly across turns in a manual run

## 2. Safe Tools

- [x] 2.1 Implement `query_service_health` as a case-insensitive lookup over a small mocked
      service table; verify by calling with a known and an unknown service name
- [x] 2.2 Implement `search_remediation_runbooks` embedding the query with
      `RETRIEVAL_QUERY` task type and querying the knowledge base by cosine similarity,
      top 2 results; verify against the seeded knowledge base with a known incident query

## 3. Agent Loop

- [x] 3.1 Implement `call_model` with the health-then-runbook system prompt and
      `extract_text` output normalization; verify a block-structured model response is
      flattened to a plain string
- [x] 3.2 Wire `agent -> safe_tools -> agent` with conditional routing, ending when no tool
      calls remain; verify with a manual run showing health check then runbook search then
      a final text response
- [x] 3.3 Configure `PostgresSaver` and `get_agent_app()`; verify state persists by invoking
      the same `thread_id` in two separate Python processes and observing continued context
