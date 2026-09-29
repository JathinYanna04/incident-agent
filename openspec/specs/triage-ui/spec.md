# triage-ui Specification

## Purpose
Provides an interactive web UI so an engineer can trigger incident triage and act on a
pending escalation approval without calling the REST API directly.

## Requirements

### Requirement: Trigger triage from the UI
The UI SHALL let a user enter a thread ID and an incident description and trigger triage,
displaying either the agent's completed response or a pending-approval notice with the
proposed action's details.

#### Scenario: Trigger with escalation pending
- **WHEN** a user enters an incident description that leads to a proposed escalation and
  triggers triage
- **THEN** the UI displays the pending action's name and parameters and indicates the
  workflow is awaiting approval

### Requirement: Approve or reject from the UI
The UI SHALL provide controls to approve or reject a pending action for the current thread,
with an optional free-text rejection reason, and SHALL update the displayed workflow state
and response once resolved.

#### Scenario: Approve in the UI
- **WHEN** a user clicks the approve control for a thread with a pending action
- **THEN** the UI updates to show the resolved state and the agent's resulting message

#### Scenario: Reject in the UI with a reason
- **WHEN** a user enters a rejection reason and clicks the reject control
- **THEN** the UI updates to show the rejected state and a response reflecting that reason

### Requirement: Handle missing input gracefully
The UI SHALL NOT attempt to trigger triage or resolve an approval without a thread ID, and
SHALL show a clear message instead.

#### Scenario: Missing thread ID
- **WHEN** a user attempts to trigger triage or resolve an approval with an empty thread ID
- **THEN** the UI displays a message asking for the missing field instead of making a request
