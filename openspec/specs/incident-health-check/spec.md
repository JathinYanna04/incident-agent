# incident-health-check Specification

## Purpose
Lets the triage agent look up the current health status of a named backend
service on demand, as the first step in investigating an incident.

## Requirements

### Requirement: Query service health by name
The system SHALL provide a way to query the current health status of a backend
service given its name, and SHALL return a human-readable status string
describing whether the service is healthy or degraded and why.

#### Scenario: Known service is healthy
- **WHEN** the health check is invoked with the name of a known, healthy service
- **THEN** the system returns a status string indicating the service is healthy,
  including any relevant metric (e.g. CPU usage)

#### Scenario: Known service is degraded
- **WHEN** the health check is invoked with the name of a known service that is
  currently degraded
- **THEN** the system returns a status string indicating the service is degraded
  and names the specific symptom (e.g. high latency on a specific endpoint)

#### Scenario: Unknown service name
- **WHEN** the health check is invoked with a service name that does not exist
  in the system's known service list
- **THEN** the system returns a clear "not found" message rather than an error
  or a false healthy/degraded status

### Requirement: Case-insensitive service lookup
The system SHALL treat service names as case-insensitive when matching against
known services.

#### Scenario: Mixed-case service name
- **WHEN** the health check is invoked with a service name in a different case
  than it is stored (e.g. "Auth" instead of "auth")
- **THEN** the system still matches it to the correct known service and returns
  its status
