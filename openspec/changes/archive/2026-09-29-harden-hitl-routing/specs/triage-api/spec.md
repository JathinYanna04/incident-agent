# Spec Delta

## MODIFIED Requirements

### Requirement: Submit an incident via REST
The system SHALL accept a thread ID and an incident message over HTTP and SHALL respond with
either a completed result or an awaiting-approval status listing **all** pending sensitive
actions and their parameters (not only the first).

#### Scenario: Incident resolves without escalation
- **WHEN** a client submits an incident message that does not require escalation
- **THEN** the response status is `COMPLETED` and includes the agent's final message

#### Scenario: Incident requires escalation
- **WHEN** a client submits an incident message that leads the agent to propose escalation
- **THEN** the response status is `AWAITING_APPROVAL` and includes a list of pending actions,
  each with its name and parameters

#### Scenario: Multiple sensitive calls in one turn
- **WHEN** a client submits an incident message that leads the agent to propose more than one
  sensitive action in the same turn
- **THEN** the response's list of pending actions includes all of them, not just the first
