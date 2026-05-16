# 🎯 Live Call Intelligence System

AI-powered real-time call intelligence system with knowledge graphs, speech processing, and intelligent response generation.

![Project Status](https://img.shields.io/badge/Status-Phase%201-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Teams](https://img.shields.io/badge/Teams-6-orange)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Team Structure](#team-structure)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## 🎯 Overview

This system processes live phone calls in real-time to:
- 🎤 Transcribe speech with speaker diarization
- 🧹 Clean audio with AI-powered denoising
- 🧠 Extract entities, intents, and sentiment
- 📊 Build knowledge graphs of conversation patterns
- 🤖 Generate intelligent AI responses
- 📈 Visualize insights in real-time dashboards

**Timeline**: 22-27 weeks | **Phase**: 1/8 | **Status**: Foundation Setup

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Twilio Voice API                     │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Kafka Audio Streaming Buffer                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│    Audio Processing (Denoising, VAD, Segmentation)      │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│         WhisperX Speech-to-Text + Diarization           │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│      NLP Pipeline (spaCy, BERT, GPT-4 Analysis)         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│          Neo4j Knowledge Graph + GDS Analytics          │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│      RAG + LangChain Response Generation System         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              TTS → Twilio → Live Response                │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

### Audio Processing
- **Twilio Voice API** - Phone call handling
- **Apache Kafka** - Audio streaming
- **FFmpeg** - Audio manipulation
- **librosa** - Audio analysis
- **NVIDIA NeMo** - AI denoising

### Speech & NLP
- **WhisperX** - Speech-to-text
- **Pyannote** - Speaker diarization
- **spaCy 3.7+** - NLP processing
- **BERT/RoBERTa** - Intent classification
- **GPT-4** - Understanding & generation

### Knowledge Graph
- **Neo4j 5.x** - Graph database
- **Neo4j GDS** - Graph algorithms
- **Redis** - Caching
- **Cypher** - Graph queries

### AI & Response
- **LangChain** - AI orchestration
- **Pinecone/Weaviate** - Vector DB
- **OpenAI API** - GPT-4 integration
- **ElevenLabs** - Text-to-speech

### Frontend
- **React + Next.js** - Web interface
- **D3.js** - Visualizations
- **Tailwind CSS** - Styling
- **Neo4j Bloom** - Graph exploration

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **AWS/GCP/Azure** - Cloud hosting
- **Prometheus + Grafana** - Monitoring

---

## 🚀 Quick Start

### Prerequisites

- Git
- Docker & Docker Compose
- Python 3.10+ (Backend/AI/Audio teams)
- Node.js 18+ (Frontend team)
- Flutter 3.x (Mobile team)

### 1. Clone Repository
```bash
git clone https://github.com/live-call-intelligence-team/live-call-intelligence.git
cd live-call-intelligence
```

### 2. Start Docker Services
```bash
# Start all infrastructure services
docker-compose -f docker-compose.dev.yml up -d

# Verify services
docker ps
```

**Services will be available at:**
- Neo4j Browser: http://localhost:7474 (neo4j / CallIntel123!)
- Database UI: http://localhost:8080
- Redis: localhost:6379
- Kafka: localhost:9092
- PostgreSQL: localhost:5432

### 3. Set Up Your Domain

#### Backend Team:
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

#### Frontend Team:
```bash
cd frontend
npm install
npm run dev
```

#### AI/ML Team:
```bash
cd ai-ml
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m spacy download en_core_web_sm
```

#### Mobile Team:
```bash
cd mobile
flutter pub get
flutter run
```

#### Audio Team:
```bash
cd audio-processing
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Verify Setup
```bash
./scripts/verify-setup.sh
```

---

## 👥 Team Structure

| Team | Responsibility | Branch |
|------|---------------|---------|
| **Backend** | FastAPI, APIs, databases | `backend/*` |
| **Frontend** | React dashboard, UI | `frontend/*` |
| **AI/ML** | Models, NLP, training | `ai-ml/*` |
| **Mobile** | Flutter apps | `mobile/*` |
| **Audio** | Streaming, denoising | `audio-processing/*` |
| **DevOps** | Infrastructure, deployment | `devops/*` |
| **Tech Leads** | Architecture, reviews | All branches |

---

## 📚 Documentation

- **[Team Workflow](docs/TEAM_WORKFLOW.md)** - Daily git workflow
- **[Onboarding Guide](docs/ONBOARDING.md)** - New team member setup
- **[Architecture](docs/architecture/)** - System design documents
- **[API Documentation](docs/api/)** - API specs and examples
- **[Setup Guides](docs/setup/)** - Detailed setup instructions
- **[Deployment](docs/deployment/)** - Production deployment guides

---

## 🤝 Contributing

### Workflow

1. **Pull latest from your team's main branch**
   ```bash
   git checkout backend/main
   git pull origin backend/main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b backend/feature/my-feature
   ```

3. **Make changes, commit, push**
   ```bash
   git add .
   git commit -m "feat: Add my feature"
   git push origin backend/feature/my-feature
   ```

4. **Create Pull Request on GitHub**
   - Base: `backend/main`
   - Compare: `backend/feature/my-feature`
   - Fill in PR template
   - Request review from team

### Commit Messages
```
type: Short description
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

### Branch Naming
```
domain/type/description
```

**Examples:**
- `backend/feature/twilio-integration`
- `frontend/fix/button-styling`
- `ai-ml/feature/whisper-model`

---

## 📊 Project Roadmap

### Phase 1: Foundation Setup (Current) ✅
- Repository structure
- Team access control
- Docker environment
- CI/CD pipelines

### Phase 2: Audio Processing Pipeline (Next)
- Twilio integration
- Kafka streaming
- Audio denoising
- VAD implementation

### Phase 3-8: See `docs/ROADMAP.md`

---

## 🔒 Security

- Never commit `.env` files
- Use environment variables for secrets
- All API keys in secure vaults
- Follow OWASP guidelines
- Regular dependency updates

---

## 📞 Support

- **Technical Issues**: Create GitHub issue
- **Access Problems**: Contact team lead
- **Questions**: GitHub Discussions or team Slack

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

## 🌟 Key Metrics

- **Total Duration**: 22-27 weeks
- **Phases**: 8 major phases
- **Technologies**: 30+ tools and frameworks
- **Target Latency**: <1.5 seconds
- **Teams**: 6 specialized domains

---

**Built with ❤️ by the Live Call Intelligence Team**