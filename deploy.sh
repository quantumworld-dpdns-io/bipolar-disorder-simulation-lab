# Project Deployment Scripts for QuantumSynapse-BD
# Target: console.choreo.dev (Docker container registry)

# Docker Compose Configuration
docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: quantumsynapse
      POSTGRES_USER: quantumsynapse
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-quantumsynapse123}
      POSTGRES_INITDB_ARGS: "--data-checksums"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./config/postgres/init:/docker-entrypoint-initdb.d
    networks:
      - quantumsynapse-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U quantumsynapse -d quantumsynapse"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: ["redis-server", "--appendonly", "yes", "--requirepass", "${REDIS_PASSWORD:-redis123}"]
    volumes:
      - redis_data:/data
    networks:
      - quantumsynapse-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  core-engine:
    build: ./services/core-engine
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://quantumsynapse:${POSTGRES_PASSWORD:-quantumsynapse123}@postgres:5432/quantumsynapse
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis123}@redis:6379/0
      JWT_SECRET: ${JWT_SECRET:-your-secret-key-here}
      IBM_QUANTUM_TOKEN: ${IBM_QUANTUM_TOKEN:-}
    networks:
      - quantumsynapse-network
    ports:
      - "8080:8080"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  quantum-worker:
    build: ./services/quantum-worker
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://quantumsynapse:${POSTGRES_PASSWORD:-quantumsynapse123}@postgres:5432/quantumsynapse
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis123}@redis:6379/0
      IBM_QUANTUM_TOKEN: ${IBM_QUANTUM_TOKEN:-}
    networks:
      - quantumsynapse-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  web:
    build: ./apps/web
    depends_on:
      - core-engine
      - quantum-worker
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8080
      NEXT_PUBLIC_WS_URL: ws://localhost:8080
      NEXT_PUBLIC_IBM_QUANTUM_API_URL: https://quantumexperience.ibm.com
    networks:
      - quantumsynapse-network
    ports:
      - "3000:3000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  quantumsynapse-network:
    driver: bridge

# Production Deployment Script
#!/bin/bash
# Deploy QuantumSynapse-BD to console.choreo.dev

set -e

echo "🚀 QuantumSynapse-BD Deployment to console.choreo.dev"

echo "\n📋 Step 1: Building Docker images..."
docker build -t quantumsynapse-bd/core-engine ./services/core-engine
docker build -t quantumsynapse-bd/quantum-worker ./services/quantum-worker
docker build -t quantumsynapse-bd/web ./apps/web

echo "\n📋 Step 2: Deploying to console.choreo.dev..."
echo "Note: Please ensure you have console.choreo.dev registry credentials"

docker tag quantumsynapse-bd/core-engine quantumsynapse-bd/core-engine:latest
docker tag quantumsynapse-bd/quantum-worker quantumsynapse-bd/quantum-worker:latest
docker tag quantumsynapse-bd/web quantumsynapse-bd/web:latest

# Push to console.choreo.dev (you'll need to provide credentials)
if docker login console.choreo.dev -u your-username; then
    echo "✅ Login successful"
    docker push quantumsynapse-bd/core-engine:latest
    docker push quantumsynapse-bd/quantum-worker:latest
    docker push quantumsynapse-bd/web:latest
    echo "✅ Images pushed to console.choreo.dev"
else
    echo "⚠️  Login failed. Please provide console.choreo.dev credentials."
    echo "   You can manually push images with: docker push quantumsynapse-bd/*"
fi

echo "\n📋 Step 3: Running smoke tests..."
cd /workspace/bipolar-simulation
./smoke-tests.sh

echo "\n📋 Step 4: Initializing databases..."
# Wait for services to be ready
sleep 10

echo "✅ Deployment completed!"
echo "\n🌐 Access your application at:"
echo "   - Frontend: http://localhost:3000"
echo "   - Core Engine API: http://localhost:8080/api/v1/health"
echo "   - Quantum Worker: http://localhost:8080/api/v1/quantum-worker/health"