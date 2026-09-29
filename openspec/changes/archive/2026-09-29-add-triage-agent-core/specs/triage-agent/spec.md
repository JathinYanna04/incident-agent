# Spec Delta

## Purpose

Provides the core agent loop that investigates an incident by checking service health and
searching the runbook knowledge base, with state persisted per conversation thread.

## ADDED Requirements

### Requirement: Health-first investigation
Given an incident description, the agent SHALL check the health of the relevant service before
searching the runbook knowledge base.

#### Scenario: Incident names a service
- **WHEN** an incident description naming a specific service is submitted
- **THEN** the agent's first tool call checks that service's health before any runbook search
  is performed

### Requirement: Runbook retrieval in response to findings
After checking health, the agent SHALL search the runbook knowledge base using a query
derived from its health findings.

#### Scenario: Degraded service triggers a runbook search
- **WHEN** a health check reports a service as degraded
- **THEN** the agent searches the runbook knowledge base for a remediation matching that
  degradation before producing its final response

### Requirement: Unknown service handled gracefully
The agent SHALL handle a health check for an unrecognized service name without raising an
error, and SHALL be able to continue reasoning using the resulting not-found message.

#### Scenario: Service name not recognized
- **WHEN** the agent checks health for a service name that does not exist
- **THEN** it receives a not-found message rather than a crash, and produces a response
  reflecting that the service is unknown

### Requirement: Conversation state persists by thread ID
The agent's message history and tool-call state SHALL be persisted keyed by a caller-supplied
thread identifier, such that a new process can resume the same conversation for that thread ID.

#### Scenario: Resume after restart
- **WHEN** a conversation under a given thread ID is created and the serving process later
  restarts
- **THEN** invoking the agent again for that thread ID continues from the persisted state
  rather than starting a blank conversation

### Requirement: Model output normalized to plain text
The agent SHALL normalize model responses to a flat string before returning them, regardless
of whether the underlying model returns a plain string or a list of content blocks.

#### Scenario: Model returns block-structured content
- **WHEN** the underlying model response content is a list of content blocks rather than a
  plain string
- **THEN** the agent's stored and returned message content is a flattened plain string
