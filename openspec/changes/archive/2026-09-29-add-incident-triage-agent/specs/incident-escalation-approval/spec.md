# Spec Delta

## Purpose

Ensures that any agent action with a real-world side effect — specifically,
escalating an incident to on-call engineers — never executes without explicit
human approval, while still letting purely investigative actions run
automatically.

## ADDED Requirements

### Requirement: Escalation halts for human approval
When the triage agent decides to escalate an incident, the system SHALL halt
execution before performing the escalation and SHALL expose the proposed
action's name and parameters to a human reviewer, rather than executing it
immediately.

#### Scenario: Agent proposes escalation
- **WHEN** the agent determines an incident requires escalation and selects the
  escalation action with a specific ticket title and severity
- **THEN** the system pauses before performing that action and reports it as
  awaiting approval, including the proposed ticket title and severity

### Requirement: Approval executes the escalation
The system SHALL provide a way for a human to approve a pending escalation,
and upon approval SHALL execute the escalation and resume the agent from
where it paused.

#### Scenario: Human approves
- **WHEN** a human approves a pending escalation for a given incident
- **THEN** the system executes the escalation (creating a ticket and notifying
  on-call), resumes the agent's reasoning, and returns a final resolution
  message confirming the escalation

### Requirement: Rejection resumes without escalating
The system SHALL provide a way for a human to reject a pending escalation with
an optional reason, and upon rejection SHALL NOT execute the escalation, but
SHALL resume the agent so it can continue reasoning (e.g. propose an
alternative remediation) using the rejection reason as context.

#### Scenario: Human rejects with a reason
- **WHEN** a human rejects a pending escalation and supplies a reason
- **THEN** the system does not create a ticket or notify on-call, feeds the
  rejection reason back into the agent's context, and resumes the agent to
  produce a further response

#### Scenario: Human rejects with no reason given
- **WHEN** a human rejects a pending escalation without supplying a reason
- **THEN** the system still resumes the agent with a generic rejection
  notice instead of failing the request

### Requirement: No pending approval yields an error
The system SHALL reject an approval or rejection request for an incident that
has no pending escalation awaiting approval, rather than silently ignoring it
or executing an escalation that was never proposed.

#### Scenario: Approve called with nothing pending
- **WHEN** an approval request is submitted for an incident thread that has no
  escalation currently awaiting approval
- **THEN** the system returns an error indicating there is no pending action
  for that thread
