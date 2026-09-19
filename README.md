# Kotodama (言霊) — Modular Multi-Agent Game Generation Service

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.12+](https://img.shields.io/badge/python-3.12+-blue.svg)](https://www.python.org/downloads/)
[![Godot 4.3+](https://img.shields.io/badge/Godot-4.3+-blue.svg?logo=godot-engine)](https://godotengine.org/)
[![Next.js 15](https://img.shields.io/badge/Next.js-15-black?logo=next.js)](https://nextjs.org/)

## 🎮 Overview

**Kotodama (言霊)** is a modular multi-agent game generation service built on Godot 4.3+. It uses **11 specialized AI agents** orchestrated via LangGraph to generate complete, playable games from natural language descriptions. The system follows a local-first architecture with three-tier uniqueness: immutable core engine, per-request content generation, and user-provided Lore RAG (Retrieval-Augmented Generation) for conceptual uniqueness.

### Core Features

- **14-Step Wizard**: Intuitive game creation with cascading compatibility logic (genre↔perspective↔art style)
- **Multi-Agent Pipeline**: 11 specialized agents (Designer, Architect, Quest Designer, Dialogue Writer, Art Director, Level Generator, Coder, QA, Playtester, Localization Manager, Prompt Refiner)
- **Three-Tier Uniqueness**: Core engine (stable), Content (generated per request), Lore RAG (user's knowledge base in PGVector)
- **Incremental Updates**: Safe module updates with automatic rollback on failure (Two-Attempt Rule)
- **Procedural Generation**: BSP, Cellular Automata, Wave Function Collapse for levels
- **Quest & Dialogue Systems**: State machine graphs and branching dialogue trees with validators
- **AI Playtester**: Automated testing with bot-player simulation (move, interact, collect, attack, talk)
- **Localization Support**: Automatic text extraction and key management
- **Asset Pipeline**: Stable Diffusion integration with 10-slot vocabulary and metadata tracking
- **Save/Load System**: Auto-generated when enabled in wizard

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Frontend (Next.js 15)                      │
│   14-Step Wizard │ Live Preview │ Lore Manager │ Dashboard     │
└─────────────────────────────────────────────────────────────────┘
                              │ WebSocket / REST API
┌─────────────────────────────────────────────────────────────────┐
│                Backend (FastAPI + LangGraph)                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Agent Orchestration Pipeline                 │ │
│  │                                                           │ │
│  │  Designer → Architect → QuestDesigner → DialogueWriter   │ │
│  │      ↓                                                 ↓  │ │
│  │  ArtDirector → LevelGenerator → Coder → QA → Playtest  │ │
│  │      ↑                                                 │  │ │
│  │      └─────── Retry (Attempt 1) ←──────────────────────┘  │ │
│  │                                    │                       │ │
│  │                                    └→ Rollback (Attempt 2) │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Database: PostgreSQL 16 + PGVector │ Storage: MinIO (S3)     │
└─────────────────────────────────────────────────────────────────┘
                              │ Headless CLI
┌─────────────────────────────────────────────────────────────────┐
│                  Godot 4.3+ Core Engine (Immutable)             │
│   Scene Manager │ Signal Bus │ State Machine │ Input System   │
│   Modules: Player │ Inventory │ Quest │ Dialogue │ Save/Load  │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start (5 Commands)

```bash
# 1. Clone repository
git clone https://github.com/your-org/kotodama.git && cd kotodama

# 2. Copy environment configuration
cp .env.example .env

# 3. Start all infrastructure services
docker-compose up -d postgres minio redis ollama

# 4. Install dependencies and run migrations
make setup

# 5. Start development server
make dev
```

Access the application at:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **MinIO Console**: http://localhost:9001 (admin / kotodama_minio_secret_k8s_key_2026)

## 📖 Complete Setup Guide

### Prerequisites

| Software | Version | Purpose |
|----------|---------|---------|
| Python | 3.12+ | Backend runtime |
| Node.js | 20+ | Frontend runtime |
| Docker | 24+ | Containerization |
| Docker Compose | 2.20+ | Multi-container orchestration |
| Godot | 4.3+ | Game engine (optional for local testing) |
| Ollama | Latest | Local LLM inference |

### Step 1: Environment Configuration

```bash
cp .env.example .env
# Edit .env with your configuration values
```

Key variables to configure:
- `DATABASE_URL`: PostgreSQL connection string
- `MINIO_SECRET_KEY`: Change to a secure random value
- `SECRET_KEY`: Minimum 32 characters for JWT signing
- `OLLAMA_BASE_URL`: Usually `http://localhost:11434`

### Step 2: Pull Ollama Models

```bash
make ollama-pull
# Or manually:
docker exec kotodama-ollama ollama pull qwen2.5-coder:32b
docker exec kotodama-ollama ollama pull qwen2.5:32b
docker exec kotodama-ollama ollama pull nomic-embed-text
```

### Step 3: Create MinIO Buckets

```bash
make minio-create-buckets
```

### Step 4: Run Migrations

```bash
make migrate
```

### Step 5: Start Development

```bash
# Backend only
make dev

# Full stack (backend + frontend)
make dev-full
```

## 📁 Project Structure

```
kotodama/
├── backend/                 # FastAPI backend (Phases 0-9)
│   ├── agents/             # 11 specialized AI agents
│   ├── api/                # REST API endpoints
│   ├── core/               # Configuration & guards
│   ├── db/                 # Database layer
│   ├── models/             # SQLAlchemy ORM models
│   ├── schemas/            # Pydantic validation schemas
│   ├── services/           # Business logic services
│   ├── utils/              # Helper functions
│   └── validators/         # Content validators
├── frontend/               # Next.js 15 frontend
│   └── app/
│       ├── components/     # UI components (shadcn/ui)
│       ├── wizard/         # 14-step game creation wizard
│       ├── store/          # Zustand state management
│       └── lib/            # Utilities
├── godot_core/             # Immutable Godot 4.3+ core
│   ├── scenes/             # Base scenes
│   └── scripts/
│       ├── core/           # Core engine scripts
│       ├── modules/        # Generated modules
│       └── bot_player/     # AI playtester bot
├── docker/                 # Docker configurations
├── configs/                # YAML/JSON configurations
├── tests/                  # Test suites (unit, integration, e2e)
├── docs/                   # Documentation
└── scripts/                # Development scripts
```

## ⚙️ Configuration

### Agent Models

| Agent | Model | Temperature |
|-------|-------|-------------|
| Designer | qwen2.5:32b | 0.6 |
| Architect | qwen2.5:32b | 0.3 |
| Coder | qwen2.5-coder:32b | 0.15 |
| Embeddings | nomic-embed-text | N/A |

### Subscription Plans

| Plan | Price | Credits/Month | Features |
|------|-------|---------------|----------|
| Free | $0 | Limited | Watermark, Web export only |
| Starter | $9.99/mo | 50 | APK export, watermark removal |
| Pro | $29.99/mo | 200 | Priority queue, HD assets |
| Studio | $99.99/mo | 1000 | White-label, API access |

## 🚢 Production Deployment

### Using Docker Compose

```bash
# Build production images
make build

# Deploy to production
make deploy

# View logs
make logs
```

### Kubernetes (Future)

Production deployment will support Kubernetes with:
- Horizontal Pod Autoscaler for backend
- Persistent Volumes for PostgreSQL, MinIO
- Ingress controller with SSL termination
- Redis cluster for caching

## 🔧 Troubleshooting

### Issue 1: Ollama Connection Refused

**Symptom**: `Connection refused` error when calling LLM APIs

**Solution**:
```bash
# Check if Ollama is running
docker ps | grep ollama

# Restart Ollama container
docker-compose restart ollama

# Verify models are loaded
docker exec kotodama-ollama ollama list
```

### Issue 2: PostgreSQL PGVector Extension Missing

**Symptom**: `extension "vector" does not exist`

**Solution**:
```bash
# Ensure using pgvector image
docker-compose up -d postgres

# Run initialization script
docker exec kotodama-postgres psql -U kotodama -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### Issue 3: MinIO Bucket Not Found

**Symptom**: `Bucket not found` error during asset generation

**Solution**:
```bash
make minio-create-buckets
# Or manually create buckets via MinIO console
```

### Issue 4: Frontend Build Fails

**Symptom**: `Module not found` errors during npm build

**Solution**:
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Issue 5: Godot Export Fails

**Symptom**: Export process hangs or fails

**Solution**:
```bash
# Check Godot version matches
docker exec kotodama-godot godot --version

# Verify export presets exist
ls -la godot_core/export_presets.cfg

# Run headless test
make godot-test
```

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Documentation**: `/docs` directory
- **API Reference**: http://localhost:8000/docs
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Built with ❤️ using Godot 4.3+, FastAPI, LangGraph, and Next.js 15**
