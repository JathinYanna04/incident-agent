# Spec Delta

## Purpose

Ensures that escalating an incident to on-call — the one agent action with a real-world side
effect — never executes without explicit human approval, while resuming correctly whether that
approval is granted or refused.

## ADDED Requirements

### Requirement: Sensitive actions require human approval
The agent MUST pause before executing any sensitive tool and MUST NOT execute it without an
explicit approval for that thread.

#### Scenario: Escalation pauses
- **WHEN** the agent decides to call `escalate_ticket` for an incident
- **THEN** execution stops before the sensitive tool runs and no ticket is created

### Requirement: Approved escalation executes
The system SHALL allow a human to approve a pending sensitive action for a thread, and upon
approval SHALL execute it exactly once and resume the agent's reasoning.

#### Scenario: Approved escalation runs once
- **WHEN** a human approves a thread paused before the sensitive tool
- **THEN** `escalate_ticket` executes exactly once and the agent produces a final response
  confirming it

### Requirement: Rejected escalation is not executed
The system SHALL allow a human to reject a pending sensitive action with an optional reason,
and upon rejection SHALL NOT execute it, but SHALL feed the rejection back to the agent so it
can continue reasoning.

#### Scenario: Rejected escalation with a reason
- **WHEN** a human rejects a thread paused before the sensitive tool, supplying a reason
- **THEN** `escalate_ticket` is never executed, and the agent's subsequent response reflects
  the supplied reason

#### Scenario: Rejected escalation with no reason
- **WHEN** a human rejects a pending sensitive action without a reason
- **THEN** the agent still resumes using a generic rejection notice instead of failing

### Requirement: Pause survives restart
A thread paused awaiting approval SHALL remain resumable after the serving process restarts.

#### Scenario: Restart while paused
- **WHEN** a thread is paused before the sensitive tool and the process restarts
- **THEN** a subsequent approval or rejection for that thread still succeeds using the
  state captured before the restart
