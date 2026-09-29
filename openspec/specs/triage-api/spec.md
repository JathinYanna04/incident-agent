# triage-api Specification

## Purpose
Exposes the triage agent and its approval gate as an HTTP API so incidents can be submitted
and pending escalations resolved without direct code access to the agent.

## Requirements

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

### Requirement: Resolve a pending approval via REST
The system SHALL accept an approval or rejection (with optional reason) for a thread over
HTTP and SHALL respond with the outcome.

#### Scenario: Approve via API
- **WHEN** a client submits an approval for a thread with a pending escalation
- **THEN** the response status is `RESOLVED` and includes the agent's resulting message

#### Scenario: Reject via API
- **WHEN** a client submits a rejection (with or without a reason) for a thread with a
  pending escalation
- **THEN** the response status is `REJECTED_AND_RESUMED` and includes the agent's resulting
  message

### Requirement: Reject approval requests with nothing pending
The system SHALL respond with an error, not a silent no-op, when an approval or rejection is
submitted for a thread with no pending sensitive action.

#### Scenario: Approve with nothing pending
- **WHEN** a client submits an approval for a thread that has no pending sensitive action
- **THEN** the API responds with an error status indicating there is nothing to approve
