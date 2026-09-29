# Spec Delta

## Purpose

Stores incident remediation runbooks with vector embeddings and lets callers retrieve the
most semantically relevant runbook(s) for a free-text query.

## ADDED Requirements

### Requirement: Runbook storage
The system SHALL store runbooks with their text content, a JSON metadata object (at minimum
identifying the affected service), and a 768-dimension embedding vector.

#### Scenario: Schema matches embedding size
- **WHEN** a runbook is inserted with a 768-dimension embedding
- **THEN** the insert succeeds and the row is retrievable with its content and metadata intact

### Requirement: Semantic retrieval function
The database SHALL expose a function that, given a query embedding, returns the runbooks
most similar to it (by cosine similarity), ordered by similarity, optionally filtered by
metadata.

#### Scenario: Filter by service
- **WHEN** the retrieval function is called with a metadata filter for a specific service
- **THEN** only runbooks whose metadata matches that service are returned

#### Scenario: Bounded result count
- **WHEN** the retrieval function is called with a match-count limit
- **THEN** no more than that many rows are returned, ordered from most to least similar

### Requirement: Idempotent seeding
Running the seed script more than once SHALL NOT create duplicate runbook rows for the same
starter content.

#### Scenario: Re-running the seed
- **WHEN** the seed script is run a second time against a database that already contains the
  starter runbooks
- **THEN** the table does not end up with duplicate rows for the same runbook content
