# Spec Delta

## Purpose

Provides the orchestrating incident triage agent that combines health checks
and runbook retrieval to investigate an incident end-to-end, exposes that
capability through a REST API and a web UI, and persists its state durably so
an in-progress or paused incident is never lost.

## ADDED Requirements

### Requirement: End-to-end incident investigation
Given a free-text incident description, the system SHALL autonomously
investigate it by checking the health of any relevant service(s) and
searching the runbook knowledge base for applicable remediations, before
deciding whether escalation is warranted.

#### Scenario: Incident describes a specific service
- **WHEN** a user submits an incident description naming a specific service
  (e.g. "auth service is timing out")
- **THEN** the agent checks that service's health, searches for a matching
  runbook, and produces a response describing its findings and any action
  taken

### Requirement: Conversation identified by thread ID
The system SHALL scope all agent state (messages, tool calls, pending
approvals) to a caller-supplied thread identifier, so that multiple incidents
can be triaged concurrently without interfering with each other.

#### Scenario: Two incidents tracked independently
- **WHEN** two incidents are submitted under two different thread IDs
- **THEN** each thread's investigation, findings, and approval state remain
  independent of the other

### Requirement: State persists across restarts
The system SHALL persist each thread's agent state to durable storage such
that an incident paused awaiting human approval can be resumed correctly
after a process restart, with no loss of prior context.

#### Scenario: Restart while awaiting approval
- **WHEN** an incident thread is paused awaiting escalation approval and the
  serving process restarts
- **THEN** a subsequent approval or rejection request for that thread still
  succeeds and resumes the agent using the state captured before the restart

### Requirement: REST API for triage and approval
The system SHALL expose an HTTP endpoint to submit an incident message for a
thread and receive either a completed response or an awaiting-approval status
with the pending action's details, and a second HTTP endpoint to approve or
reject a pending action for a thread.

#### Scenario: Submit incident via API
- **WHEN** a client sends an incident message and thread ID to the triage
  endpoint
- **THEN** the API responds with either a completed result or an
  awaiting-approval status naming the pending action and its parameters

#### Scenario: Resolve via API
- **WHEN** a client sends an approval or rejection for a thread's pending
  action to the approval endpoint
- **THEN** the API responds with the resulting status (resolved, or rejected
  and resumed) and the agent's resulting message

### Requirement: Interactive UI for triage and approval
The system SHALL provide a web-based UI where a user can enter a thread ID and
incident description to trigger triage, view the agent's findings or pending
approval request, and approve or reject a pending action with an optional
reason.

#### Scenario: Trigger and approve via UI
- **WHEN** a user enters an incident description in the UI and triggers
  triage, and the agent proposes an escalation
- **THEN** the UI displays the pending action and its parameters, and offers
  controls to approve or reject it, updating the displayed workflow state and
  response once resolved
