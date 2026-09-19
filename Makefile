# =============================================================================
# KOTODAMA - Makefile (AMD Ryzen AI Max 395 / qwen3-coder + qwen3.6)
# =============================================================================

.PHONY: help setup dev dev-backend test build deploy backup clean lint migrate docker-up docker-down logs ollama-pull minio-create-buckets

# Colors (PowerShell-friendly — без ANSI escape кодов для Windows)
help:
	@echo "Kotodama - Modular Multi-Agent Game Generation Service"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  setup              Initial project setup"
	@echo "  dev                Start backend in dev mode (uvicorn --reload)"
	@echo "  dev-backend        Start backend only"
	@echo "  test               Run all tests"
	@echo "  test-unit          Run unit tests"
	@echo "  build              Build production Docker images"
	@echo "  migrate            Run database migrations"
	@echo "  docker-up          Start all Docker services"
	@echo "  docker-down        Stop all Docker services"
	@echo "  logs               View service logs"
	@echo "  ollama-pull        Pull required Ollama models"
	@echo "  minio-create-buckets  Create MinIO buckets"

# -----------------------------------------------------------------------------
# SETUP
# -----------------------------------------------------------------------------
setup:
	@echo "[SETUP] Installing Python dependencies..."
	pip install -r requirements.txt
	@echo "[SETUP] Starting infrastructure..."
	docker compose up -d postgres minio redis ollama
	@echo "[SETUP] Waiting for services..."
	sleep 10
	@echo "[SETUP] Creating MinIO buckets..."
	-make minio-create-buckets
	@echo "[SETUP] Setup complete!"

# -----------------------------------------------------------------------------
# DEVELOPMENT (запуск локально, без Docker — самый быстрый путь)
# -----------------------------------------------------------------------------
dev:
	@echo "[DEV] Starting backend with hot-reload..."
	uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

dev-backend: dev

# -----------------------------------------------------------------------------
# TESTING
# -----------------------------------------------------------------------------
test:
	pytest tests/ -v --cov=backend --cov-report=html

test-unit:
	pytest backend/tests/unit -v

test-integration:
	pytest backend/tests/integration -v

test-e2e:
	pytest backend/tests/e2e -v

# -----------------------------------------------------------------------------
# BUILD
# -----------------------------------------------------------------------------
build:
	docker compose build

build-backend:
	docker build -f docker/Dockerfile.backend -t kotodama-backend:latest .

# -----------------------------------------------------------------------------
# DATABASE
# -----------------------------------------------------------------------------
migrate:
	@echo "[DB] Running Alembic migrations..."
	alembic upgrade head

migrate-status:
	alembic current

# -----------------------------------------------------------------------------
# DOCKER SERVICES
# -----------------------------------------------------------------------------
docker-up:
	docker compose up -d

docker-down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

# -----------------------------------------------------------------------------
# OLLAMA MODELS (обновлено под ваши локальные модели)
# -----------------------------------------------------------------------------
ollama-pull:
	@echo "[OLLAMA] Models already on host via bind mount:"
	docker exec kotodama-ollama ollama list
	@echo "[OLLAMA] Pulling nomic-embed-text for RAG..."
	docker exec kotodama-ollama ollama pull nomic-embed-text

ollama-list:
	docker exec kotodama-ollama ollama list

# -----------------------------------------------------------------------------
# MINIO
# -----------------------------------------------------------------------------
minio-create-buckets:
	@echo "[MINIO] Installing mc client if missing..."
	docker exec kotodama-minio mc alias set myminio http://localhost:9000 kotodama_admin kotodama_minio_secret_k8s_key_2026 || true
	docker exec kotodama-minio mc mb myminio/kotodama-assets --ignore-existing || true
	docker exec kotodama-minio mc mb myminio/kotodama-builds --ignore-existing || true

minio-console:
	@echo "MinIO Console: http://localhost:9001"
	@echo "Login: kotodama_admin / kotodama_minio_secret_k8s_key_2026"

# -----------------------------------------------------------------------------
# CLEANUP
# -----------------------------------------------------------------------------
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf build/ dist/ .pytest_cache/ .coverage htmlcov/