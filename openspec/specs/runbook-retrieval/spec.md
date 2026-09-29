# runbook-retrieval Specification

## Purpose
Lets the triage agent find the most relevant remediation runbook(s) for an
incident by semantic similarity, instead of requiring exact keyword matches
against a knowledge base of prior incident documentation.

## Requirements

### Requirement: Semantic search over runbook knowledge base
The system SHALL maintain a knowledge base of remediation runbooks, each
stored with a vector embedding of its content, and SHALL support querying
this knowledge base with a free-text query to retrieve the most semantically
similar runbook(s).

#### Scenario: Query matches an existing runbook
- **WHEN** a query describing a known incident symptom (e.g. "auth service high
  latency on token refresh") is submitted
- **THEN** the system returns the runbook(s) whose content is most semantically
  similar to the query, including which service each matched runbook applies to

#### Scenario: No relevant runbook exists
- **WHEN** a query is submitted and the knowledge base contains no documents
- **THEN** the system returns a clear "no relevant runbooks found" result rather
  than an error or an empty/ambiguous response

### Requirement: Bounded result set
The system SHALL limit the number of runbooks returned for a single query to a
small, fixed maximum so results stay relevant and easy to reason about.

#### Scenario: Query matches many runbooks
- **WHEN** a query is semantically similar to more runbooks than the configured
  maximum
- **THEN** the system returns only the top-ranked runbooks up to that maximum,
  ordered by similarity
