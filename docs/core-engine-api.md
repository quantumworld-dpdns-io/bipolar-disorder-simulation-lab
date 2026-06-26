# API Contracts Documentation

Based on the selected Polyglot Architecture, this project supports two alternative API contract approaches:

- **OpenAPI (Recommended)**: Standardized specification for polyglot communication
- **tRPC**: TypeScript-first approach (frontend→Go, Python→REST fallback)

## OpenAPI Specification

The OpenAPI spec is the most polyglot-friendly approach:
- Generates idiomatic clients for Next.js (TypeScript), Go (client library), and Python (OpenAPI client)
- Enables contract testing between services
- Supports both generated and manual API implementations
- Provides tooling for validation and documentation

### Installation

```bash
npm install @openapitools/openapi-generator-cli
pip install openapi-spec-validator
```

### OpenAPI Definition Files

#### Core Engine API (`/docs/core-engine-api.yaml`)
```yaml
openapi: 3.0.3
info:
  title: QuantumSynapse-BD Core Engine API
  description: Core simulation backend with pharmacodynamics and WebSocket support
  version: 1.0.0
  contact:
    name: API Support
    email: support@quantumsynapse.local
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html

servers:
  - url: https://api.quantumsynapse.local
    description: Production server
  - url: http://localhost:8080
    description: Development server

paths:
  /api/v1/auth/login:
    post:
      tags:
        - Authentication
      summary: User login
      description: Authenticate user and return JWT token
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LoginRequest'
            example:
              email: "user@example.com"
              password: "password123"
      responses:
        '200':
          description: Login successful
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LoginResponse'
              example:
                token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        '401':
          description: Invalid credentials
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              example:
                error: "Invalid credentials"
                code: "ERROR_INVALID_CREDENTIALS"

  /api/v1/simulations:
    post:
      tags:
        - Simulations
      summary: Create new simulation
      description: Submit a new pharmacodynamics or quantum simulation job
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateSimulationRequest'
      responses:
        '201':
          description: Simulation created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SimulationResponse'
        '400':
          description: Invalid request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

    get:
      tags:
        - Simulations
      summary: List user simulations
      description: Get list of simulations for the authenticated user
      parameters:
        - $ref: '#/components/parameters/XRequestID'
        - $ref: '#/components/parameters/XUserID'
      responses:
        '200':
          description: List of simulations
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/SimulationResponse'

  /api/v1/simulations/{simulationId}:
    get:
      tags:
        - Simulations
      summary: Get simulation details
      description: Retrieve specific simulation by ID
      parameters:
        - $ref: '#/components/parameters/SimulationID'
      responses:
        '200':
          description: Simulation details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SimulationResponse'
        '404':
          description: Simulation not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /api/v1/simulations/{simulationId}/result:
    get:
      tags:
        - Simulations
      summary: Get simulation result
      description: Retrieve simulation result when available
      parameters:
        - $ref: '#/components/parameters/SimulationID'
      responses:
        '200':
          description: Simulation result
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SimulationResultResponse'
        '202':
          description: Simulation still processing
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProcessingResponse'

  /api/v1/quantum-jobs:
    post:
      tags:
        - Quantum Jobs
      summary: Queue quantum computation job
      description: Submit quantum calculation request (SMILES → VQE)
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/QuantumJobRequest'
      responses:
        '202':
          description: Job queued successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/QuantumJobResponse'
        '400':
          description: Invalid request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /api/v1/quantum-jobs/{jobId}:
    get:
      tags:
        - Quantum Jobs
      summary: Get quantum job status
      description: Check status of quantum computation job
      parameters:
        - $ref: '#/components/parameters/QuantumJobID'
      responses:
        '200':
          description: Job status
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/QuantumJobResponse'
        '404':
          description: Job not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /api/v1/health:
    get:
      tags:
        - System
      summary: Health check
      description: Service health status endpoint
      responses:
        '200':
          description: Service healthy
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/HealthResponse'

  /ws/simulations/{simulationId}:
    get:
      tags:
        - WebSocket
      summary: WebSocket simulation updates
      description: Real-time simulation progress updates via WebSocket
      parameters:
        - $ref: '#/components/parameters/SimulationID'
      responses:
        '101':
          description: Switching protocols
          headers:
            Upgrade:
              schema:
                type: string
              example: "websocket"
            Connection:
              schema:
                type: string
              example: "Upgrade"
        '400':
          description: Upgrade failed

components:
  schemas:
    LoginRequest:
      type: object
      required:
        - email
        - password
      properties:
        email:
          type: string
          format: email
          example: "user@example.com"
        password:
          type: string
          format: password
          example: "password123"

    LoginResponse:
      type: object
      required:
        - token
      properties:
        token:
          type: string
          example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

    CreateSimulationRequest:
      type: object
      required:
        - name
        - type
        - parameters
      properties:
        name:
          type: string
          example: "Bipolar Treatment Simulation"
        type:
          type: string
          enum: [CLASSICAL_DRUG_SIMULATION, QUANTUM_DE_NOVO_SYNTHESIS]
          example: "CLASSICAL_DRUG_SIMULATION"
        parameters:
          type: object
          example:
            initial_concentration: 1.0
            rate: 0.1
            duration: 24.0
            drug_id: "drug_123"
        drugId:
          type: string
          example: "drug_123"

    SimulationResponse:
      type: object
      required:
        - id
        - name
        - type
        - status
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          example: "sim_202401011234567890"
        name:
          type: string
          example: "Bipolar Treatment Simulation"
        type:
          type: string
          example: "CLASSICAL_DRUG_SIMULATION"
        parameters:
          type: object
          example:
            initial_concentration: 1.0
            rate: 0.1
            duration: 24.0
            drug_id: "drug_123"
        status:
          type: string
          enum: [PENDING, RUNNING, COMPLETED, FAILED]
          example: "PENDING"
        result:
          type: object
          nullable: true
        error:
          type: string
          nullable: true
        createdAt:
          type: string
          format: date-time
          example: "2024-01-01T12:34:56Z"
        completedAt:
          type: string
          format: date-time
          nullable: true
          example: "2024-01-01T14:34:56Z"

    SimulationResultResponse:
      type: object
      required:
        - status
        - result
      properties:
        status:
          type: string
          example: "COMPLETED"
        result:
          type: object
          example:
            concentrations: [0.1, 0.5, 1.0, ...]
            peak_concentration: 1.0
        error:
          type: string
          nullable: true

    ProcessingResponse:
      type: object
      required:
        - status
      properties:
        status:
          type: string
          example: "RUNNING"

    QuantumJobRequest:
      type: object
      required:
        - molecule_smiles
      properties:
        molecule_smiles:
          type: string
          example: "C1=CC=CC=C1"  # Benzene SMILES
        molecule_structure:
          type: object
          description: 3D coordinates and molecular structure
          example:
            atoms: ["C", "C", "C", "C", "C", "C"]
            bonds: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
            coordinates:
              - [0.0, 0.0, 0.0]
              - [1.4, 0.0, 0.0]
              - [2.1, 0.0, 0.0]
              - [2.8, 0.0, 0.0]
              - [3.5, 0.0, 0.0]
              - [1.4, 1.2, 0.0]

    QuantumJobResponse:
      type: object
      required:
        - id
        - status
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          example: "job_202401011234567890"
        molecule_smiles:
          type: string
          example: "C1=CC=CC=C1"
        molecule_structure:
          type: object
        status:
          type: string
          enum: [QUEUED, PROCESSING, COMPLETED, FAILED]
          example: "QUEUED"
        createdAt:
          type: string
          format: date-time
          example: "2024-01-01T12:34:56Z"
        completedAt:
          type: string
          format: date-time
          nullable: true
          example: "2024-01-01T14:34:56Z"
        result:
          type: object
          nullable: true

    Error:
      type: object
      required:
        - error
        - code
      properties:
        error:
          type: string
          example: "Resource not found"
        code:
          type: string
          example: "ERROR_NOT_FOUND"
        details:
          type: object
          nullable: true

    HealthResponse:
      type: object
      required:
        - status
        - version
      properties:
        status:
          type: string
          example: "healthy"
        version:
          type: string
          example: "1.0.0"
        uptime:
          type: number
          example: 3600
        timestamp:
          type: string
          format: date-time
          example: "2024-01-01T12:34:56Z"

  parameters:
    XRequestID:
      name: X-Request-ID
      in: header
      description: Unique request identifier for tracing
      required: false
      schema:
        type: string
        example: "req_123456789"

    XUserID:
      name: X-User-ID
      in: header
      description: User ID for authentication
      required: false
      schema:
        type: string
        example: "user_123"

    SimulationID:
      name: simulationId
      in: path
      required: true
      schema:
        type: string
        example: "sim_123456789"

    QuantumJobID:
      name: jobId
      in: path
      required: true
      schema:
        type: string
        example: "job_123456789"

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  examples:
    classicalSimulationRequest:
      summary: Example classical simulation request
      value:
        name: "Lithium Treatment Response"
        type: "CLASSICAL_DRUG_SIMULATION"
        parameters:
          initial_concentration: 1.0
          rate: 0.1
          duration: 24.0
          drug_id: "drug_001"

    quantumJobRequest:
      summary: Example quantum job request
      value:
        molecule_smiles: "C1=CC=CC=C1"
        molecule_structure:
          atoms: ["C", "C", "C", "C", "C", "C"]
          bonds: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
          coordinates:
            - [0.0, 0.0, 0.0]
            - [1.4, 0.0, 0.0]
            - [2.1, 0.0, 0.0]
            - [2.8, 0.0, 0.0]
            - [3.5, 0.0, 0.0]
            - [1.4, 1.2, 0.0]

  tags:
    - name: Authentication
      description: User authentication and authorization
    - name: Simulations
      description: Classical drug simulation management
    - name: Quantum Jobs
      description: Quantum computation job management
    - name: System
      description: System health and monitoring
    - name: WebSocket
      description: Real-time updates and streaming
```

## Security Considerations

Given the nature of quantum chemical simulations and pharmaceutical data, the API requires:

1. **Authentication**: JWT-based authentication for all endpoints
2. **Authorization**: Role-based access control (USER/ADMIN)
3. **Data Protection**: SSL/TLS for all API communications
4. **Rate Limiting**: Prevent abuse and ensure fair resource usage
5. **Input Validation**: Comprehensive validation for SMILES strings and molecular structures
6. **Audit Logging**: Track all API calls for compliance and debugging

## Integration Guide

### Frontend Integration

The Next.js frontend will be generated using OpenAPI client code:

```bash
openapi-generator generate -i docs/core-engine-api.yaml -g typescript-axios -o apps/web/src/lib/api
```

### Backend Integration

Core Engine will use the same OpenAPI spec as:
- Reference implementation
- Contract tests
- OpenAPI generator CLI for server stubs
- Integration between Go and Python services

### Testing Strategy

1. **Contract Testing**: Using the OpenAPI spec as the source of truth
2. **Semantic Validation**: Validating API contracts across language boundaries
3. **Business Logic Testing**: Testing the actual pharmacodynamics and quantum computations
4. **Integration Testing**: Testing the entire pipeline from frontend to quantum worker

## API Response Patterns

### Success Responses
- All successful responses return appropriate HTTP status codes
- Consistent error format for all API calls
- Includes metadata (timestamps, request IDs) for observability

### Error Responses
- Standardized error format with user-friendly messages
- Detailed error codes for client-side handling
- Includes debugging information in development environments

### WebSocket Events
- Real-time simulation progress updates
- Standardized event types and payload structures
- Automatic reconnection handling

## Versioning Strategy

The API will be versioned using:
- URL path prefixes (`/api/v1/`)
- Semantic versioning based on breaking changes
- Backward compatibility for existing clients
- Clear deprecation notices for deprecated endpoints

## Monitoring and Observability

The OpenAPI specification includes:
- Health check endpoints for each service
- Structured logging for all API calls
- Metrics for API usage and performance
- Tracing for distributed system observability

## Implementation Notes

1. **Validation**: Strict validation of input parameters (especially SMILES strings)
2. **Rate Limiting**: Implement rate limiting to prevent abuse
3. **Caching**: Implement caching for expensive operations
4. **Error Handling**: Comprehensive error handling and recovery
5. **Documentation**: Continuous API documentation maintenance

This OpenAPI specification provides a solid foundation for the polyglot architecture, ensuring consistent API contracts across all services and enabling robust testing and integration strategies.