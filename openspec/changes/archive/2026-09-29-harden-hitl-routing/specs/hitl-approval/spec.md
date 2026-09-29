# Spec Delta

## MODIFIED Requirements

### Requirement: Sensitive actions require human approval
The agent MUST pause before executing a model turn if **any** of its tool calls is sensitive,
and MUST NOT execute any sensitive tool without explicit approval for that thread. This
applies regardless of the position of the sensitive call within the turn's tool calls.

#### Scenario: Escalation pauses
- **WHEN** the agent decides to call `escalate_ticket` for an incident
- **THEN** execution stops before the sensitive tool runs and no ticket is created

#### Scenario: Mixed safe and sensitive calls in one turn
- **WHEN** the model returns a turn containing both a safe tool call and a sensitive tool
  call, with the sensitive call not first
- **THEN** the entire turn is routed through the approval gate before either call executes

## ADDED Requirements

### Requirement: Rejection answers every pending call in the turn
When a paused turn contains more than one tool call, rejecting it SHALL supply a tool result
for every pending call in that turn, not only the sensitive one, so the agent can resume
without an unanswered tool call.

#### Scenario: Reject a mixed turn
- **WHEN** a human rejects a paused turn containing both a safe call and a sensitive call
- **THEN** both calls receive a tool result and the sensitive call is not executed
