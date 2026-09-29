# deployment Specification

## Purpose
Makes the triage agent's API and UI reachable on the public internet on a free hosting tier,
without losing paused-incident state across the platform's cold starts.

## Requirements

### Requirement: Service binds to the platform-provided port
The service SHALL bind to the port supplied by the hosting platform's `PORT` environment
variable at runtime, rather than a hardcoded port.

#### Scenario: Platform assigns a port
- **WHEN** the hosting platform sets the `PORT` environment variable to a given value at
  startup
- **THEN** the running service accepts connections on that port

### Requirement: Health check endpoint
The service SHALL expose an HTTP endpoint that returns a successful response without calling
the LLM provider or the database, suitable for platform health checks.

#### Scenario: Health check without external calls
- **WHEN** the health check endpoint is requested
- **THEN** it responds successfully without making a request to Gemini or Postgres

### Requirement: Secrets excluded from source control
The system SHALL source all secrets (API keys, database URLs) from environment variables, and
the repository SHALL NOT contain a committed file with real secret values.

#### Scenario: Environment file not tracked
- **WHEN** the repository's tracked files are inspected
- **THEN** no file containing real secret values (such as a populated `.env`) is present

### Requirement: Paused state survives a cold start
An incident thread paused awaiting escalation approval SHALL remain resumable after the
service restarts due to the platform's free-tier spin-down/cold-start behavior.

#### Scenario: Approval after cold start
- **WHEN** a thread is paused awaiting approval, the service spins down from inactivity, and a
  new instance starts to serve the next request
- **THEN** submitting the approval for that thread still resumes and resolves it correctly
