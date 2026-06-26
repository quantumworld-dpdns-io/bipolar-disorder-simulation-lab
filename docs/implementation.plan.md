# Implementation Plan

Based on the user's selections, this project will use:

- **API Contracts**: OpenAPI spec + generated clients for all services
- **DB Schema**: Prisma ORM for PostgreSQL
- **Core Backend**: Go (Echo) with WebSocket + ODE solver
- **Quantum Worker**: Python with Qiskit + Celery + Redis
- **Frontend**: Next.js with TypeScript, React Three Fiber
- **Observability**: OpenTelemetry + Cloudflare Workers Logs
- **State Management**: React Context + useReducer
- **Auth**: Custom JWT + PostgreSQL users
- **Deployment**: All on Cloudflare (Workers + Containers)
- **Communication**: OpenAPI for polyglot compatibility
- **Testing**: Vitest + Go test + pytest

## Project Structure

```
quantumsynapse-bd/
├── README.md
├── docs/
│   ├── structure.md
│   ├── implementation.plan.md
│   └── api-spec.yaml           # OpenAPI spec
├── apps/
│   └── web/
│       ├── public/
│       │   └── __generated__/
│       │       └── __generated__.js  # OpenAPI client code
│       ├── src/
│       │   ├── components/
│       │   │   ├── lab/               # Laboratory controls, progress bar
│       │   │   └── r3f/              # React Three Fiber render core
│       │   ├── hooks/               # Custom React hooks (useQuantumJob, etc.)
│       │   ├── app/                 # Next.js App Router pages
│       │   └── lib/                # WebSocket and API clients
│       │
│       └── package.json
├── services/
│   ├── core-engine/               # Core simulation backend (Go)
│   │   ├── src/
│   │   │   ├── models/            # Biochemical state models
│   │   │   ├── pharmacodynamics/  # Classical drug effects (Hill Equation)
│   │   │   └── websocket/        # Real-time data streaming
│   │   ├── Dockerfile
│   │   └── go.mod
│   └── quantum-worker/            # IBM Quantum / Qiskit microservice (Python)
│       ├── src/
│       │   ├── celery_app.py      # Asynchronous task queue
│       │   └── quantum_circuits/  # Qiskit quantum circuits
│       │       ├── vqe_solver.py  # Variational Quantum Eigensolver
│       │       └── molecule_builder.py  # SMILES to quantum Hamiltonian
│       └── docker-compose.yml
├── config/                        # Configuration
│   ├── postgres/                 # Database initialization
│   │   ├── schema.prisma         # Prisma data model
│   │   └── migrations/
│   └── cloudflare/               # wrangler.toml (Edge routing)
└── docs/
    ├── setup-guide.md
    └── api-contracts.md
```

## Phase 1: Setup & Infrastructure

### 1.1 Project Initialization
- [ ] Set up monorepo with Turborepo or Nx
- [ ] Initialize all service repositories
- [ ] Set up shared config (tsconfig, linting, prettierrc)

### 1.2 Infrastructure Setup
- [ ] Create PostgreSQL database with Prisma schema
- [ ] Set up Redis for Celery
- [ ] Configure Docker volumes and networks
- [ ] Initialize GitHub Actions/CI workflows

### 1.3 OpenAPI Specification
- [ ] Create `/docs/api-spec.yaml` with all endpoints
- [ ] Generate Next.js client types
- [ ] Generate Go server stubs
- [ ] Generate Python client
- [ ] Set up API gateway/Wrangler routes

## Phase 2: Database & Core Backend

### 2.1 Database Schema (Prisma)
```prisma
model User {
  id            String   @id @default(cuid())
  email         String   @unique
  passwordHash  String
  name          String?
  role          Role     @default(USER)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  simulations   Simulation[]
}

model Drug {
  id          String   @id @default(cuid())
  name        String
  description String?
  smiles      String   // RDKit SMILES
  molecularWeight Float
  isClassical Boolean @default(true)
  createdAt   DateTime @default(now())
  simulations Simulation[]
}

model QuantumJob {
  id            String   @id @default(cuid())
  moleculeSMILES String
  moleculeStructure JSON // 3D coordinates
  status        JobStatus @default(QUEUED)
  createdAt     DateTime @default(now())
  completedAt   DateTime?
  result        JSON?
  error         String?
  user          User     @relation(fields: [userId], references: [id])
  userId        String
}

model Simulation {
  id              String   @id @default(cuid())
  name            String
  type            SimulationType
  parameters      JSON
  status          SimulationStatus @default(PENDING)
  createdAt       DateTime @default(now())
  completedAt     DateTime?
  result          JSON?
  error           String?
  user            User     @relation(fields: [userId], references: [id])
  userId          String
  drug            Drug?    @relation(fields: [drugId], references: [id])
  drugId          String?
}

enum Role {
  USER
  ADMIN
}

enum JobStatus {
  QUEUED
  RUNNING
  COMPLETED
  FAILED
}

enum SimulationType {
  CLASSICAL_DRUG_SIMULATION
  QUANTUM_DE_NOVO_SYNTHESIS
}

enum SimulationStatus {
  PENDING
  RUNNING
  COMPLETED
  FAILED
}
```

### 2.2 Core Engine (Go)
- [ ] Create Go module with Echo framework
- [ ] Implement WebSocket server for real-time updates
- [ ] Build ODE solver for pharmacodynamics (Hill equation)
- [ ] Create OpenAPI server documentation
- [ ] Implement API endpoints for Drug simulation
- [ ] Add JWT authentication middleware
- [ ] Set up structured logging with OpenTelemetry
- [ ] Write unit tests (Go test)

### 2.3 API Endpoints (Core Engine)
```yaml
/openapi: 3.0.0
info:
  title: QuantumSynapse-BD Core Engine API
  version: 1.0.0
paths:
  /api/v1/auth/login:
    post:
      summary: User login
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email: {type: string}
                password: {type: string}
      responses:
        '200': {description: Login successful}
  /api/v1/simulations:
    post:
      summary: Create new simulation
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                name: {type: string}
                type: {type: string}
                parameters: {type: object}
                drugId: {type: string}
      responses:
        '201': {description: Simulation created}
  /api/v1/simulations/{id}/result:
    get:
      summary: Get simulation result
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200': {description: Simulation result}
  /api/v1/quantum-jobs:
    post:
      summary: Queue quantum calculation
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                moleculeSMILES: {type: string}
                moleculeStructure: {type: object}
      responses:
        '202': {description: Job queued}
  /api/v1/quantum-jobs/{id}/status:
    get:
      summary: Get quantum job status
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200': {description: Job status}
```

## Phase 3: Quantum Worker

### 3.1 Quantum Microservice Setup
- [ ] Create Python virtual environment
- [ ] Set up Celery with Redis broker
- [ ] Install Qiskit Nature, RDKit, Celery
- [ ] Implement VQE solver with Jordan-Wigner transformation
- [ ] Create molecule builder from SMILES
- [ ] Set up IBM Quantum integration
- [ ] Write unit/integration tests (pytest)

### 3.2 Quantum Worker Components
```python
# services/quantum-worker/src/quantum_worker/quantum_circuits/vqe_solver.py
from qiskit_nature.second_q.problems import ElectronicStructureProblem
from qiskit_nature.second_q.algorithms import VQE
from qiskit_nature.second_q.transformers import JordanWignerTransformer

def solve_vqe(molecule_smiles, molecule_structure):
    # Build molecular Hamiltonian
    # Configure VQE parameters
    # Execute on IBM Quantum
    # Return ground state energy
    pass

# services/quantum-worker/src/celery_app.py
from celery import Celery
import os

app = Celery('quantum_worker')
app.config_from_object('django.conf:settings', namespace='CELERY')

@app.task
@shared_task
def process_quantum_job(job_id, molecule_smiles, molecule_structure):
    # Process quantum calculation
    # Update database with results
    # Emit WebSocket event
    pass
```

## Phase 4: Frontend

### 4.1 Next.js Application Setup
- [ ] Set up Next.js with TypeScript
- [ ] Install React Three Fiber dependencies
- [ ] Create WebSocket client
- [ ] Set up OpenTelemetry instrumentation
- [ ] Install shared components from @/shared/ui
- [ ] Configure Cloudflare Workers integration

### 4.2 Application Features
- [ ] Auth provider with JWT handling
- [ ] Simulation results dashboard
- [ ] 3D synaptic visualization (R3F)
- [ ] Real-time WebSocket updates
- [ ] Drug search and selection interface
- [ ] Quantum job monitoring (progress bar)
- [ ] Lab transition animation (immersive waiting)
- [ ] Responsive dark/light theme

### 4.3 Frontend Components
```typescript
// apps/web/src/components/lab/LaboratoryDashboard.tsx
interface Simulation {
  id: string
  name: string
  type: 'CLASSICAL_DRUG_SIMULATION' | 'QUANTUM_DE_NOVO_SYNTHESIS'
  status: 'PENDING' | 'RUNNING' | 'COMPLETED' | 'FAILED'
  result?: JSON
}

// apps/web/src/hooks/useWebSocket.tsx
const useWebSocket = (url: string) => {
  // WebSocket connection logic
  // Reconnect handling
  // Message parsing
  // Connection state management
}

// apps/web/src/components/r3f/SynapseScene.tsx
const SynapseScene = () => {
  // R3F scene setup
  // Particle system for neurotransmitters
  // Receptor visualization
  // WebSocket event handling for real-time updates
  // Immersive quantum waiting state transitions
}
```

## Phase 5: Deployment & Integration

### 5.1 Docker Configuration
- [ ] Build multi-arch Docker images for all services
- [ ] Set up PostgreSQL, Redis, and other services
- [ ] Configure Cloudflare Workers for edge routing
- [ ] Set up CI/CD pipelines

### 5.2 Production Deployment
```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: quantumsynapse
      POSTGRES_USER: quantumsynapse
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app_network

  core-engine:
    build: ./services/core-engine
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgresql://quantumsynapse:${POSTGRES_PASSWORD}@postgres:5432/quantumsynapse
      REDIS_URL: redis://redis:6379
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - postgres
      - redis
    networks:
      - app_network

  quantum-worker:
    build: ./services/quantum-worker
    environment:
      DATABASE_URL: postgresql://quantumsynapse:${POSTGRES_PASSWORD}@postgres:5432/quantumsynapse
      REDIS_URL: redis://redis:6379
      IBM_QUANTUM_TOKEN: ${IBM_QUANTUM_TOKEN}
    depends_on:
      - postgres
      - redis
    networks:
      - app_network

  web:
    build: ./apps/web
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: https://api.quantumsynapse.local
      NEXT_PUBLIC_WS_URL: wss://api.quantumsynapse.local
    depends_on:
      - core-engine
    networks:
      - app_network

networks:
  app_network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

### 5.3 Cloudflare Configuration
- [ ] Set up Wrangler configuration
- [ ] Configure Workers for API routing
- [ ] Set up PostgreSQL integration
- [ ] Configure observability (logs, metrics)

## Phase 6: Testing & Quality Assurance

### 6.1 Testing Strategy
- [ ] Unit tests (Vitest + Go test + pytest)
- [ ] Integration tests (Playwright e2e tests)
- [ ] Contract tests (OpenAPI validation)
- [ ] Performance tests for WebSocket updates
- [ ] Load testing for quantum calculations

### 6.2 Development Workflow
```bash
# Test all services
npm test               # Vitest for frontend
go test ./...         # Go tests
pytest services/quantum-worker/ -v  # Python tests

# Linting
npm run lint          # Frontend lint
golangci-lint run     # Go lint
pylint services/quantum-worker/  # Python lint

# Type checking
npx tsc --noEmit       # TypeScript

# API validation
swagger-cli validate docs/api-spec.yaml
```

## Phase 7: Maintenance & Operations

### 7.1 Monitoring
- [ ] Set up OpenTelemetry exporters
- [ ] Configure Grafana dashboards
- [ ] Set up alerting for failed jobs
- [ ] Performance monitoring

### 7.2 Maintenance
- [ ] Automated database migrations
- [ ] Health checks for all services
- [ ] Backup and disaster recovery
- [ ] Performance tuning

## Current Implementation Status

### Completed
- ✅ Project structure defined
- ✅ API contracts specified (OpenAPI)
- ✅ Technology stack chosen
- ✅ PostgreSQL schema designed (Prisma)
- ✅ Component blueprint established

### In Progress
- 📋 Infrastructure setup (PostgreSQL, Redis, Docker)
- 📋 OpenAPI specification creation
- 📋 Core engine (Go) setup

### Next Steps
1. Start infrastructure setup
2. Create OpenAPI spec
3. Initialize Go project
4. Implement database schema

