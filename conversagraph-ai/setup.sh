#!/bin/bash

# ============================================================
# ConversaGraph AI - Complete Setup Script
# ============================================================
# This script sets up the entire ConversaGraph AI platform
# Usage: chmod +x setup.sh && ./setup.sh
# ============================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

# ==================== SYSTEM CHECKS ====================

print_header "STEP 1: Checking System Requirements"

MISSING_DEPS=0

# Check Python
if check_command python3; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_info "Python version: $PYTHON_VERSION"
else
    print_error "Python 3.10+ is required"
    MISSING_DEPS=1
fi

# Check Node.js
if check_command node; then
    NODE_VERSION=$(node --version)
    print_info "Node.js version: $NODE_VERSION"
else
    print_error "Node.js 18+ is required"
    MISSING_DEPS=1
fi

# Check Docker
if check_command docker; then
    DOCKER_VERSION=$(docker --version)
    print_info "Docker version: $DOCKER_VERSION"
else
    print_error "Docker is required"
    MISSING_DEPS=1
fi

# Check Docker Compose
if check_command docker-compose; then
    COMPOSE_VERSION=$(docker-compose --version)
    print_info "Docker Compose version: $COMPOSE_VERSION"
else
    print_error "Docker Compose is required"
    MISSING_DEPS=1
fi

# Check pip
if check_command pip3; then
    print_success "pip3 is available"
else
    print_error "pip3 is required"
    MISSING_DEPS=1
fi

# Check npm
if check_command npm; then
    NPM_VERSION=$(npm --version)
    print_info "npm version: $NPM_VERSION"
else
    print_error "npm is required"
    MISSING_DEPS=1
fi

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Missing required dependencies. Please install them and run again."
    exit 1
fi

print_success "All system requirements satisfied!"

# ==================== PROJECT STRUCTURE ====================

print_header "STEP 2: Creating Project Structure"

# Create directories if they don't exist
mkdir -p backend/{api,services,models,utils}
mkdir -p aiml/{audio-processing,nlp,models}
mkdir -p frontend/src/{components,hooks,services,utils}
mkdir -p database/{neo4j,migrations}
mkdir -p infrastructure/{docker,kubernetes,prometheus,grafana}
mkdir -p docs
mkdir -p scripts
mkdir -p tests/{unit,integration,load}
mkdir -p logs

print_success "Project structure created"

# ==================== DOCKER SERVICES ====================

print_header "STEP 3: Starting Docker Services"

print_info "Starting Neo4j, Redis, PostgreSQL, Kafka..."

if docker-compose up -d; then
    print_success "Docker services started successfully"
else
    print_error "Failed to start Docker services"
    exit 1
fi

# Wait for services to be ready
print_info "Waiting for services to be ready..."
sleep 15

# Check Neo4j
if curl -s http://localhost:7474 > /dev/null; then
    print_success "Neo4j is ready (http://localhost:7474)"
else
    print_warning "Neo4j may not be ready yet"
fi

# Check Redis
if docker exec conversagraph-redis redis-cli -a redis123 ping > /dev/null 2>&1; then
    print_success "Redis is ready"
else
    print_warning "Redis may not be ready yet"
fi

print_success "All Docker services started"

# ==================== PYTHON ENVIRONMENT ====================

print_header "STEP 4: Setting Up Python Environment"

# Create virtual environment
if [ ! -d "venv" ]; then
    print_info "Creating Python virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
else
    print_info "Virtual environment already exists"
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
print_info "Upgrading pip..."
pip install --upgrade pip > /dev/null 2>&1
print_success "pip upgraded"

# Install Python dependencies
print_info "Installing Python dependencies (this may take a while)..."
if pip install -r requirements.txt > /dev/null 2>&1; then
    print_success "Python dependencies installed"
else
    print_error "Failed to install Python dependencies"
    print_info "Trying with verbose output..."
    pip install -r requirements.txt
fi

# Download spaCy model
print_info "Downloading spaCy language model..."
python -m spacy download en_core_web_lg > /dev/null 2>&1
print_success "spaCy model downloaded"

print_success "Python environment ready"

# ==================== AI MODELS ====================

print_header "STEP 5: Downloading AI Models"

print_info "Creating AI models download script..."

cat > scripts/download_models.py << 'PYTHON_SCRIPT'
"""Download required AI/ML models"""
import os
from transformers import (
    AutoTokenizer, AutoModel, pipeline,
    AutoModelForSequenceClassification
)

print("Downloading AI models...")

# Sentiment Analysis Model
print("• BERT Sentiment Model...")
pipeline("sentiment-analysis", 
         model="nlptown/bert-base-multilingual-uncased-sentiment")

# Emotion Classification
print("• Emotion Classifier...")
pipeline("text-classification",
         model="j-hartmann/emotion-english-distilroberta-base")

# Named Entity Recognition
print("• NER Model...")
pipeline("ner", model="dslim/bert-base-NER")

# Zero-shot Classification
print("• Zero-shot Classifier...")
pipeline("zero-shot-classification", 
         model="facebook/bart-large-mnli")

# Sentence Transformers
print("• Sentence Embeddings...")
AutoTokenizer.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")
AutoModel.from_pretrained("sentence-transformers/all-MiniLM-L6-v2")

print("\n✓ All AI models downloaded successfully!")
PYTHON_SCRIPT

python scripts/download_models.py

print_success "AI models downloaded"

# ==================== NEO4J INITIALIZATION ====================

print_header "STEP 6: Initializing Neo4j Database"

print_info "Waiting for Neo4j to be fully ready..."
sleep 10

print_info "Loading Neo4j schema..."

# Run Cypher script
docker exec -i conversagraph-neo4j cypher-shell \
    -u neo4j -p password123 \
    < database/neo4j_schema.cypher > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "Neo4j schema initialized"
else
    print_warning "Neo4j schema initialization may have failed (check manually)"
fi

# ==================== FRONTEND SETUP ====================

print_header "STEP 7: Setting Up Frontend"

cd frontend

# Install npm dependencies
print_info "Installing npm dependencies..."
if npm install > /dev/null 2>&1; then
    print_success "npm dependencies installed"
else
    print_error "Failed to install npm dependencies"
    npm install
fi

cd ..

print_success "Frontend setup complete"

# ==================== ENVIRONMENT CONFIGURATION ====================

print_header "STEP 8: Creating Environment Configuration"

# Backend .env
cat > backend/.env << ENV_FILE
# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
SECRET_KEY=$(openssl rand -hex 32)

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password123

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis123

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=conversagraph
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=conversagraph_metadata

# AI Models
HUGGINGFACE_TOKEN=
MODEL_CACHE_DIR=./models

# Logging
LOG_LEVEL=INFO
ENV_FILE

print_success "Backend .env created"

# Frontend .env
cat > frontend/.env << FRONTEND_ENV
REACT_APP_API_URL=http://localhost:8000
REACT_APP_WS_URL=ws://localhost:8000
FRONTEND_ENV

print_success "Frontend .env created"

# ==================== CREATE STARTUP SCRIPTS ====================

print_header "STEP 9: Creating Startup Scripts"

# Backend startup script
cat > start_backend.sh << 'BACKEND_SCRIPT'
#!/bin/bash
source venv/bin/activate
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
BACKEND_SCRIPT

chmod +x start_backend.sh
print_success "Backend startup script created"

# Frontend startup script
cat > start_frontend.sh << 'FRONTEND_SCRIPT'
#!/bin/bash
cd frontend
npm start
FRONTEND_SCRIPT

chmod +x start_frontend.sh
print_success "Frontend startup script created"

# All-in-one startup script
cat > start_all.sh << 'ALL_SCRIPT'
#!/bin/bash
echo "Starting ConversaGraph AI..."

# Start Docker services
echo "1. Starting Docker services..."
docker-compose up -d

# Wait for services
echo "2. Waiting for services..."
sleep 10

# Start backend in background
echo "3. Starting backend API..."
./start_backend.sh > logs/backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to start
sleep 5

# Start frontend
echo "4. Starting frontend..."
./start_frontend.sh > logs/frontend.log 2>&1 &
FRONTEND_PID=$!

echo ""
echo "✓ ConversaGraph AI is starting!"
echo ""
echo "Access points:"
echo "• Frontend:      http://localhost:3000"
echo "• Backend API:   http://localhost:8000"
echo "• API Docs:      http://localhost:8000/docs"
echo "• Neo4j Browser: http://localhost:7474"
echo "• Redis UI:      http://localhost:8081"
echo ""
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "To stop: ./stop_all.sh"
ALL_SCRIPT

chmod +x start_all.sh
print_success "All-in-one startup script created"

# Stop all script
cat > stop_all.sh << 'STOP_SCRIPT'
#!/bin/bash
echo "Stopping ConversaGraph AI..."

# Stop frontend
pkill -f "npm start"

# Stop backend
pkill -f "uvicorn"

# Stop Docker services
docker-compose down

echo "✓ All services stopped"
STOP_SCRIPT

chmod +x stop_all.sh
print_success "Stop script created"

# ==================== VERIFICATION ====================

print_header "STEP 10: Verification"

# Check services
print_info "Checking service status..."

SERVICES_OK=1

if docker ps | grep -q conversagraph-neo4j; then
    print_success "Neo4j is running"
else
    print_error "Neo4j is not running"
    SERVICES_OK=0
fi

if docker ps | grep -q conversagraph-redis; then
    print_success "Redis is running"
else
    print_error "Redis is not running"
    SERVICES_OK=0
fi

if docker ps | grep -q conversagraph-postgres; then
    print_success "PostgreSQL is running"
else
    print_error "PostgreSQL is not running"
    SERVICES_OK=0
fi

# ==================== COMPLETION ====================

print_header "SETUP COMPLETE!"

echo -e "${GREEN}"
cat << "LOGO"
   ____                                       ____                 _     
  / ___|___  _ ____   _____ _ __ ___  __ _  / ___|_ __ __ _ _ __ | |__  
 | |   / _ \| '_ \ \ / / _ \ '__/ __|/ _` || |  _| '__/ _` | '_ \| '_ \ 
 | |__| (_) | | | \ V /  __/ |  \__ \ (_| || |_| | | | (_| | |_) | | | |
  \____\___/|_| |_|\_/ \___|_|  |___/\__,_| \____|_|  \__,_| .__/|_| |_|
                                                             |_|          
                              AI
LOGO
echo -e "${NC}"

print_success "Setup completed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Start all services:  ./start_all.sh"
echo "  2. Access frontend:     http://localhost:3000"
echo "  3. Access API docs:     http://localhost:8000/docs"
echo "  4. Access Neo4j:        http://localhost:7474 (neo4j/password123)"
echo ""
print_info "To start individual services:"
echo "  • Backend only:  ./start_backend.sh"
echo "  • Frontend only: ./start_frontend.sh"
echo ""
print_info "To stop all services: ./stop_all.sh"
echo ""
print_info "Documentation: See COMPLETE_IMPLEMENTATION_GUIDE.md"
echo ""

if [ $SERVICES_OK -eq 1 ]; then
    print_success "All services are ready!"
else
    print_warning "Some services may need attention"
fi

echo ""
print_info "🚀 Ready to revolutionize conversational intelligence!"
