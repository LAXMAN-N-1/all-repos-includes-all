# 🚀 ConversaGraph AI - Enterprise Conversational Intelligence Platform

> **Advanced real-time conversation analysis with Neo4j knowledge graphs, multi-model AI, and predictive analytics**

[![Python](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-green.svg)](https://fastapi.tiangolo.com/)
[![Neo4j](https://img.shields.io/badge/Neo4j-5.15+-red.svg)](https://neo4j.com/)
[![React](https://img.shields.io/badge/React-18+-blue.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Knowledge Graph](#-knowledge-graph)
- [AI Models](#-ai-models)
- [Configuration](#-configuration)
- [Development](#-development)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎯 Core Capabilities

- **Real-Time Audio Processing**
  - Advanced noise reduction with spectral gating
  - MFCC, spectral, and temporal feature extraction
  - Voice activity detection
  - Audio quality assessment (SNR, clarity)

- **Multi-Dimensional AI Analysis**
  - BERT-based sentiment analysis (5-star ratings)
  - 7-category emotion detection (joy, sadness, anger, fear, surprise, trust, disgust)
  - Advanced NER with 15+ entity types
  - Zero-shot intent classification
  - Topic modeling with LDA
  - Sentence embeddings for semantic similarity

- **Neo4j Knowledge Graphs**
  - Complex multi-node schema (Conversation, Speaker, Transcript, Entity, Topic, Sentiment, Intent)
  - 8+ relationship types with properties
  - Graph algorithms: PageRank, Louvain Community Detection, Centrality measures
  - Custom Cypher queries
  - Graph projections for analysis

- **Predictive Analytics**
  - Churn risk prediction with confidence scores
  - Conversion probability estimation
  - Deal value forecasting
  - Next-best-action recommendations
  - Customer lifetime value calculation

- **Real-Time Communication**
  - WebSocket for live transcription
  - Sub-second latency
  - Speaker diarization
  - Real-time sentiment tracking
  - Live AI co-pilot suggestions

### 🎨 Advanced UI/UX

- **Interactive Dashboards**
  - Real-time metrics (WPM, sentiment, engagement, energy)
  - Team performance tracking
  - Conversation quality scores
  - Historical trends

- **Knowledge Graph Visualization**
  - Force-directed graph layout
  - Interactive node exploration
  - Community highlighting
  - Relationship filtering

- **Theme Support**
  - Dark, Light, and Medium themes
  - Responsive design
  - Accessibility features
  - Mobile-friendly

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│         React 18 + TailwindCSS + WebSocket                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ REST API / WebSocket
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                      Backend API                             │
│              FastAPI + Async Python                          │
├──────────────────────────────────────────────────────────────┤
│  • Audio Processing  • NLP Engine  • Graph Manager           │
│  • ML Predictor     • WebSocket    • Redis Cache             │
└─────┬──────────┬──────────┬────────────┬─────────────────────┘
      │          │          │            │
      │          │          │            │
┌─────▼──┐  ┌───▼────┐  ┌──▼────┐  ┌───▼─────┐
│ Neo4j  │  │ Redis  │  │ Kafka │  │ Postgres│
│ Graph  │  │ Cache  │  │Stream │  │   DB    │
└────────┘  └────────┘  └───────┘  └─────────┘
```

### Tech Stack

#### Backend
- **FastAPI** - Modern async web framework
- **Neo4j 5.15** - Graph database with GDS
- **Redis 7** - In-memory caching
- **PostgreSQL 15** - Relational data
- **Apache Kafka** - Event streaming

#### AI/ML
- **Transformers** (HuggingFace) - NLP models
- **spaCy** - Advanced NLP pipeline
- **Librosa** - Audio feature extraction
- **scikit-learn** - ML algorithms
- **NetworkX** - Graph analytics
- **PyTorch** - Deep learning

#### Frontend
- **React 18** - UI library
- **TailwindCSS** - Styling
- **Lucide Icons** - Icon library
- **Axios** - HTTP client

---

## 🚀 Quick Start

### One-Command Setup (Recommended)

```bash
# Clone repository
git clone https://github.com/yourorg/conversagraph-ai.git
cd conversagraph-ai

# Run automated setup
chmod +x setup.sh
./setup.sh

# Start all services
./start_all.sh
```

**That's it!** Open http://localhost:3000 in your browser.

### Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | - |
| Backend API | http://localhost:8000 | - |
| API Docs | http://localhost:8000/docs | - |
| Neo4j Browser | http://localhost:7474 | neo4j / password123 |
| Redis Commander | http://localhost:8081 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin123 |

---

## 📦 Installation

### Prerequisites

- **Python 3.10+**
- **Node.js 18+**
- **Docker & Docker Compose**
- **8GB RAM minimum** (16GB recommended)
- **10GB free disk space**

### Manual Installation

#### 1. System Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y python3.10 python3-pip python3-venv \
    nodejs npm docker.io docker-compose \
    build-essential libsndfile1 ffmpeg
```

**macOS:**
```bash
brew install python@3.10 node docker docker-compose ffmpeg
```

**Windows:**
- Install Python from https://python.org
- Install Node.js from https://nodejs.org
- Install Docker Desktop from https://docker.com

#### 2. Clone Repository

```bash
git clone https://github.com/yourorg/conversagraph-ai.git
cd conversagraph-ai
```

#### 3. Backend Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Download spaCy model
python -m spacy download en_core_web_lg

# Download AI models
python scripts/download_models.py
```

#### 4. Start Docker Services

```bash
docker-compose up -d

# Wait for services to be ready
sleep 15

# Verify services
docker-compose ps
```

#### 5. Initialize Neo4j

```bash
# Load schema
docker exec -i conversagraph-neo4j cypher-shell \
    -u neo4j -p password123 \
    < database/neo4j_schema.cypher

# Verify
docker exec conversagraph-neo4j cypher-shell \
    -u neo4j -p password123 \
    "CALL db.constraints();"
```

#### 6. Frontend Setup

```bash
cd frontend
npm install
cd ..
```

#### 7. Start Services

```bash
# Terminal 1 - Backend
cd backend
source ../venv/bin/activate
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Terminal 2 - Frontend
cd frontend
npm start
```

---

## 💻 Usage

### Basic Workflow

1. **Start Recording**
   - Open http://localhost:3000
   - Click "Live Capture" tab
   - Click "Start Recording" button
   - Grant microphone permissions

2. **Speak Naturally**
   - Real-time transcription appears
   - Sentiment analysis updates live
   - AI co-pilot provides suggestions

3. **Stop & Analyze**
   - Click "Stop Recording"
   - Comprehensive AI analysis begins
   - View results in "Analysis" tab

4. **Explore Knowledge Graph**
   - Navigate to "Knowledge Graph" tab
   - Interact with nodes and relationships
   - Run graph algorithms
   - View community detection results

### API Usage

```python
import requests

# Create conversation
response = requests.post('http://localhost:8000/api/conversations/create', json={
    'segments': [
        {
            'text': 'Hello, how can I help you?',
            'speaker_id': 'agent_001',
            'timestamp': 0,
            'confidence': 0.95
        }
    ],
    'speakers': [
        {'id': 'agent_001', 'name': 'Agent', 'role': 'agent'}
    ],
    'duration': 1800
})

conversation_id = response.json()['conversation_id']

# Get comprehensive analysis
analysis = requests.post('http://localhost:8000/api/analyze/comprehensive', json={
    'conversation_id': conversation_id
}).json()

# Get knowledge graph
graph = requests.get(
    f'http://localhost:8000/api/conversations/{conversation_id}/graph'
).json()
```

---

## 📚 API Documentation

### Interactive API Docs

Visit http://localhost:8000/docs for:
- Complete API reference
- Try-it-out functionality
- Request/response schemas
- Authentication details

### Key Endpoints

#### Conversations

```
POST   /api/conversations/create       - Create conversation
GET    /api/conversations/{id}         - Get conversation
GET    /api/conversations/{id}/graph   - Get knowledge graph
DELETE /api/conversations/{id}         - Delete conversation
GET    /api/conversations/search       - Search conversations
```

#### Analysis

```
POST   /api/analyze/comprehensive      - Full analysis
POST   /api/analyze/sentiment          - Sentiment only
POST   /api/analyze/entities           - Entity extraction
POST   /api/analyze/topics             - Topic modeling
POST   /api/analyze/intents            - Intent detection
GET    /api/analyze/{id}/predictions   - Predictive insights
```

#### Graph Algorithms

```
GET    /api/graph/{id}                    - Get graph data
POST   /api/graph/algorithms/pagerank     - PageRank
POST   /api/graph/algorithms/communities  - Community detection
POST   /api/graph/algorithms/centrality   - Centrality measures
POST   /api/graph/query                   - Custom Cypher
```

#### WebSocket

```
WS     /ws/transcribe                  - Real-time transcription
```

---

## 🕸️ Knowledge Graph

### Graph Schema

```cypher
// Node Types
(:Conversation {id, timestamp, duration, quality_score})
(:Speaker {id, name, role})
(:Transcript {id, text, timestamp, confidence})
(:Entity {text, type, confidence})
(:Topic {name, keywords, weight})
(:Sentiment {score, polarity, subjectivity})
(:Intent {type, confidence})

// Relationships
(Speaker)-[:PARTICIPATED_IN {word_count, talk_time}]->(Conversation)
(Speaker)-[:SPOKE]->(Transcript)
(Transcript)-[:PART_OF]->(Conversation)
(Transcript)-[:HAS_SENTIMENT]->(Sentiment)
(Entity)-[:MENTIONED_IN {count}]->(Conversation)
(Entity)-[:CO_OCCURS_WITH {count}]-(Entity)
(Topic)-[:DISCUSSED_IN {relevance}]->(Conversation)
(Intent)-[:DETECTED_IN {confidence}]->(Conversation)
```

### Sample Queries

**Find high-quality conversations:**
```cypher
MATCH (c:Conversation)
WHERE c.quality_score > 80
RETURN c.id, c.timestamp, c.quality_score
ORDER BY c.quality_score DESC
LIMIT 10
```

**Analyze speaker performance:**
```cypher
MATCH (s:Speaker)-[p:PARTICIPATED_IN]->(c:Conversation)
WITH s, 
     count(c) AS total_conversations,
     avg(p.sentiment) AS avg_sentiment,
     avg(c.quality_score) AS avg_quality
RETURN s.name, total_conversations, 
       round(avg_sentiment, 2) AS sentiment,
       round(avg_quality, 2) AS quality
ORDER BY quality DESC
```

**Entity co-occurrence network:**
```cypher
MATCH (e1:Entity)-[r:CO_OCCURS_WITH]-(e2:Entity)
WHERE r.count > 3
RETURN e1.text, e1.type, e2.text, e2.type, r.count
ORDER BY r.count DESC
LIMIT 50
```

### Graph Algorithms

**PageRank:**
```cypher
CALL gds.pageRank.stream('entity-network')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).text AS entity, score
ORDER BY score DESC LIMIT 10
```

**Community Detection:**
```cypher
CALL gds.louvain.stream('entity-network')
YIELD nodeId, communityId
RETURN communityId, collect(gds.util.asNode(nodeId).text) AS members
ORDER BY size(members) DESC
```

---

## 🤖 AI Models

### NLP Models

| Model | Purpose | Provider |
|-------|---------|----------|
| BERT Sentiment | 5-star sentiment analysis | nlptown |
| RoBERTa Emotion | 7-emotion classification | j-hartmann |
| BERT NER | Entity recognition | dslim |
| BART Zero-shot | Intent classification | Facebook |
| MiniLM | Sentence embeddings | sentence-transformers |

### Audio Processing

- **Librosa** - Feature extraction (MFCC, spectral, temporal)
- **Noisereduce** - Advanced noise reduction
- **WebRTCVAD** - Voice activity detection
- **SciPy** - Signal processing

### Machine Learning

- **scikit-learn** - Topic modeling, clustering
- **NetworkX** - Graph analytics
- **NumPy** - Numerical computing

---

## ⚙️ Configuration

### Environment Variables

**Backend (.env):**
```env
# API
API_HOST=0.0.0.0
API_PORT=8000
SECRET_KEY=your-secret-key

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
```

**Frontend (.env):**
```env
REACT_APP_API_URL=http://localhost:8000
REACT_APP_WS_URL=ws://localhost:8000
```

---

## 🛠️ Development

### Running Tests

```bash
# Backend tests
pytest backend/tests/ -v --cov

# Frontend tests
cd frontend && npm test

# Integration tests
pytest tests/integration/ -v

# Load testing
locust -f tests/load/locustfile.py
```

### Code Quality

```bash
# Linting
flake8 backend/
black backend/ --check
isort backend/ --check

# Type checking
mypy backend/

# Frontend linting
cd frontend && npm run lint
```

### Adding New Features

1. Create feature branch: `git checkout -b feature/new-feature`
2. Implement changes
3. Add tests
4. Update documentation
5. Submit pull request

---

## 🚀 Deployment

### Docker Production

```bash
# Build images
docker-compose -f docker-compose.prod.yml build

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Scale services
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

### Kubernetes

```bash
# Deploy to cluster
kubectl apply -f infrastructure/kubernetes/

# Check status
kubectl get pods -n conversagraph

# Scale deployment
kubectl scale deployment backend --replicas=5
```

### Cloud Deployment

- **AWS**: Use ECS, EKS, or Elastic Beanstalk
- **GCP**: Use Cloud Run, GKE, or App Engine
- **Azure**: Use AKS, Container Instances, or App Service

---

## 📊 Monitoring

### Metrics

- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **Custom metrics** - Request latency, error rates, graph query performance

### Logging

- Structured JSON logs
- Log levels: DEBUG, INFO, WARN, ERROR
- Centralized logging with ELK stack (optional)

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork
3. Create feature branch
4. Make changes
5. Add tests
6. Submit pull request

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Neo4j** - Graph database platform
- **HuggingFace** - NLP models
- **FastAPI** - Web framework
- **React** - Frontend library
- All open-source contributors

---

## 📞 Support

- **Documentation**: [Full docs](https://docs.conversagraph.ai)
- **Issues**: [GitHub Issues](https://github.com/yourorg/conversagraph-ai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourorg/conversagraph-ai/discussions)
- **Email**: support@conversagraph.ai

---

## 🎯 Roadmap

- [ ] Multi-language support
- [ ] Video call analysis
- [ ] Advanced voice biometrics
- [ ] Custom model training
- [ ] Mobile apps (iOS/Android)
- [ ] Microsoft Teams integration
- [ ] Zoom integration
- [ ] Salesforce connector

---

**Made with ❤️ by the ConversaGraph Team**

⭐ Star us on GitHub if you find this useful!
