# Tasks

## 1. Sensitive Tool & Routing

- [x] 1.1 Implement `escalate_ticket(ticket_title, severity)` as a sensitive tool; verify by
      calling it directly and confirming the returned confirmation string
- [x] 1.2 Split `all_tools` into `safe_tools` and `sensitive_tools`, and add a `sensitive_tools`
      `ToolNode` to the graph; verify the graph compiles without error

## 2. Interrupt & Resume

- [x] 2.1 Compile the graph with `interrupt_before=["sensitive_tools"]`; verify by submitting
      an incident that leads to escalation and confirming `get_state(config).next` includes
      `sensitive_tools` before any ticket is created
- [x] 2.2 Implement the approval path (`invoke(None, config)` after approval); verify the
      pending `escalate_ticket` call executes exactly once and a final response is produced
- [x] 2.3 Implement the rejection path (`update_state(..., as_node="sensitive_tools")` with a
      `ToolMessage`, then resume); verify with both a supplied reason and no reason, confirming
      no ticket is created in either case
- [x] 2.4 Verify pause-then-restart: pause a thread awaiting approval, start a fresh process
      pointed at the same `DATABASE_URL`, and confirm approval still resumes correctly
