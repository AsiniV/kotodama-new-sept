# Kotodama Developer Guide

Welcome to the **Kotodama** development team! This guide covers everything you need to know to maintain, extend, and deploy the platform. Kotodama is a complex system combining AI orchestration, procedural generation, and game engine automation. Read carefully before making changes.

---

## 1. Architecture

### Data Flow Diagram

```text
┌──────────────┐      ┌─────────────────────────────────────────────────────────────────┐
│   Frontend   │      │                      BACKEND (FastAPI + LangGraph)              │
│   (Next.js)  │      │                                                                 │
│              │      │  ┌─────────────┐    ┌───────────────────────────────────────┐   │
│  Wizard Req  │─────▶│  │ Job Manager │───▶│          ORCHESTRATOR                 │   │
│  (WebSocket) │      │  │ (Redis Lock)│    │  (LangGraph State Machine)            │   │
│              │      │  └─────────────┘    └──────────────┬────────────────────────┘   │
│  Live Logs   │◀─────│                                    │                           │
│  (Stream)    │      │                                    ▼                           │
│              │      │  ┌─────────────────────────────────────────────────────────┐   │
│  Preview     │◀─────│  │                    AGENT PIPELINE                       │   │
│  (Web/APK)   │      │  │                                                         │   │
│              │      │  │  [START]                                                │   │
│  Lore Mgmt   │◀─────│  │    │                                                    │   │
│  (RAG)       │      │  │    ▼                                                    │   │
│              │      │  │  1. Game Designer ────▶ GDD (JSON)                      │   │
│  Marketplace │◀─────│  │    │                                                    │   │
│  (Modules)   │      │  │    ▼                                                    │   │
│              │      │  │  2. Architect ────────▶ ArchitecturePlan + Signals      │   │
│              │      │  │    │                                                    │   │
│              │      │  │    ├──────────────┬──────────────┬──────────────┐       │   │
│              │      │  │    ▼              ▼              ▼              ▼       │   │
│              │      │  │  3.Quest        4.Dialogue     5.Art          6.Level   │   │
│              │      │  │    Designer       Writer         Director       Generator │   │
│              │      │  │    (Graph)        (Tree)         (Prompts)      (Layout)  │   │
│              │      │  │    │              │              │              │         │   │
│              │      │  │    └──────────────┴──────────────┴──────────────┘         │   │
│              │      │  │                          │                                │   │
│              │      │  │                          ▼                                │   │
│              │      │  │                    7. Coder (GDScript)                    │   │
│              │      │  │                          │                                │   │
│              │      │  │                          ▼                                │   │
│              │      │  │                    8. QA Validator                        │   │
│              │      │  │                          │                                │   │
│              │      │  │           ┌──────────────┴──────────────┐                 │   │
│              │      │  │           │ Pass?                       │                 │   │
│              │      │  │           ├──────YES────▶ 9. Playtester │                 │   │
│              │      │  │           │             │ (Headless)    │                 │   │
│              │      │  │           │             │               │                 │   │
│              │      │  │           │             ▼               │                 │   │
│              │      │  │           │      Stable?                │                 │   │
│              │      │  │           ├──────YES────▶ 10. Committer │                 │   │
│              │      │  │           │             │ (Git+MinIO)   │                 │   │
│              │      │  │           │             ▼               │                 │   │
│              │      │  │           │          [END]              │                 │   │
│              │      │  │           │                             │                 │   │
│              │      │  │           └────NO────▶ [Retry Logic]    │                 │   │
│              │      │  │                         │               │                 │   │
│              │      │  │                         └──(Attempt 2)─▶│                 │   │
│              │      │  │                                         │                 │   │
│              │      │  │                         └──(Fail)──────▶│ [ROLLBACK]      │   │
│              │      │  └─────────────────────────────────────────┘                 │   │
│              │      │                        │                                     │   │
│              │      │                        ▼                                     │   │
│              │      │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌─────────┐ │   │
│              │      │  │ PostgreSQL │  │   MinIO    │  │   Redis    │  │ Ollama  │ │   │
│              │      │  │ + PGVector │  │  (Assets)  │  │   (Cache)  │  │ (LLM)   │ │   │
│              │      │  └────────────┘  └────────────┘  └────────────┘  └─────────┘ │   │
└──────────────┘      └─────────────────────────────────────────────────────────────────┘
```

### How the 11 Agents Work

The agents are orchestrated via **LangGraph**, forming a state machine with conditional edges. Each agent is a Python class inheriting from `BaseAgent`, receiving the current `GenerationState` and returning an updated state.

| # | Agent | Input | Output | Responsibility |
|---|-------|-------|--------|----------------|
| 1 | **Game Designer** | WizardInput, LoreContext | `GameDesignDocument` | Converts user request + RAG lore into structured JSON GDD. |
| 2 | **Architect** | GDD | `ArchitecturePlan` | Plans scene structure, module list, and Signal contracts. |
| 3 | **Quest Designer** | GDD, ArchPlan | `QuestGraph[]` | Generates state-machine graphs for quests (stages, conditions). |
| 4 | **Dialogue Writer** | GDD, Quests, Lore | `DialogueTree[]` | Creates branching dialogue trees linked to quests/NPCs. |
| 5 | **Art Director** | ArchPlan, Lore | `AssetMetadata[]` | Selects asset slots (10-slot vocab), generates SD prompts, manages metadata. |
| 6 | **Level Generator** | ArchPlan | `LevelLayout` | Runs procedural algorithms (BSP, CA, WFC) based on parameters. |
| 7 | **Coder** | All above | `GeneratedFile[]` | Writes clean GDScript modules (strictly avoiding Core). |
| 8 | **QA & Integrator** | GeneratedFiles | `QAReport` | Static analysis (syntax, signals, guards, asset refs). |
| 9 | **AI Playtester** | Workspace | `PlaytestReport` | Spawns Headless Godot, runs bot simulation, collects metrics. |
| 10 | **Prompt Refiner** | History | `UpdatedPrompts` | (Async) Analyzes success/failure patterns to update system prompts. |
| 11 | **Localization Manager** | GeneratedFiles | `LocalizationFiles` | Extracts strings, generates `en.json`, validates `tr()` keys. |

**Routing Logic:**
- If `QAReport.errors > 0` → Retry **Coder** (Max 2 attempts).
- If `PlaytestReport.stability < 60` → Retry **Architect/Coder** (Max 2 attempts).
- If Attempt 2 fails → Trigger **Rollback**.

### How the Signal Bus is Structured

The communication backbone is the **Global Signal Bus** (`godot_core/scripts/core/global_signal_bus.gd`).

- **Core Signals**: Immutable, defined in the engine kernel (e.g., `core_game_over`, `core_scene_loaded`).
- **Module Channels**: Dynamic, registered at runtime via `register_channel(module_id, signal_name)`.
- **Contract Enforcement**:
    - Publishers must declare output signals in `module_config.json`.
    - Subscribers must declare input signals.
    - **QA Agent** verifies that every declared signal has at least one publisher and one subscriber (unless optional).
    - **No Direct References**: Modules never use `get_node("../OtherModule")`. They only emit/listen.

```gdscript
# Example Usage in Generated Module
GlobalSignalBus.module_enemy_defeated.emit(score)

# Listener
func _ready():
    GlobalSignalBus.module_enemy_defeated.connect(_on_enemy_defeated)
```

### How Fail-Safe / Rollback Works

**Two-Attempt Rule:**

1.  **Attempt 1**:
    - Assets are generated and committed to Git/MinIO *first*.
    - Code generation proceeds.
    - If QA or Playtest fails:
        - **Credits NOT charged**.
        - System performs **Soft Rollback**: Reverts code files to previous commit, keeps assets.
        - User sees: "Generation hiccup! Retrying automatically..."

2.  **Attempt 2**:
    - Uses refined prompts based on Attempt 1 error logs.
    - If failed:
        - **Credits CHARGED** (compensation for compute).
        - **Hard Rollback**: Reverts code AND deletes new assets.
        - User sees: "Complex request failed. Please simplify or contact support."

**Implementation Details:**
- Every workspace is a Git repo initialized on creation.
- `WorkspaceManager` creates a `pre-generation` tag before starting.
- On failure: `git reset --hard pre-generation` + `minio_client.remove_object(new_assets)`.
- Asset preservation is guaranteed because assets are committed *before* code generation begins.

---

## 2. Local Development

### Setup

Ensure Docker Desktop (with WSL2 on Windows) and Make are installed.

```bash
# Clone and enter directory
git clone https://github.com/kotodama/kotodama.git && cd kotodama

# Initialize environment
cp .env.example .env
# Edit .env if needed (defaults work for most local setups)

# Run full setup (pulls images, downloads Ollama models, initializes DB)
make setup
```

This command will:
- Pull all Docker images (Postgres, MinIO, Ollama, etc.).
- Download LLM models via Ollama (`qwen2.5-coder:32b`, `qwen2.5:32b`, `nomic-embed-text`).
- Initialize PostgreSQL with PGVector extension.
- Create MinIO buckets (`kotodama-assets`, `kotodama-builds`).
- Install Python and Node dependencies.

### Run in Dev Mode

```bash
# Starts all services with hot-reload enabled
make dev
```

- **Backend**: `uvicorn` with `--reload` on port 8000.
- **Frontend**: `next dev` on port 3000.
- **Database**: Postgres on 5432.
- **Ollama**: Running locally, exposing 11434.
- **MinIO**: API on 9000, Console on 9001.

Access points:
- Frontend: `http://localhost:3000`
- API Docs (Swagger): `http://localhost:8000/docs`
- MinIO Console: `http://localhost:9001` (credentials in `.env`)
- Ollama: `http://localhost:11434`

### Hot Reload

- **Python**: Changes in `backend/` trigger automatic server restart via `uvicorn --reload`.
- **React/Next.js**: Changes in `frontend/` trigger fast refresh.
- **Godot**: Scripts are not hot-reloaded in real-time during generation. To test changes to the Core Engine, you must manually copy the updated `godot_core/` files to a test project or regenerate a game.

### How to Add a New Agent to LangGraph

1.  **Define the Agent Class** in `backend/agents/my_new_agent.py`:
    ```python
    from backend.agents.base import BaseAgent
    from backend.schemas.state import GenerationState

    class MyNewAgent(BaseAgent):
        async def process(self, state: GenerationState) -> GenerationState:
            """Process logic for the new agent."""
            # Access LLM via self.llm
            response = await self.llm.invoke(state.current_context)
            
            # Update state
            state.my_new_data = response.content
            return state
    ```

2.  **Register in Graph** in `backend/orchestration/graph.py`:
    ```python
    from backend.agents.my_new_agent import MyNewAgent

    def build_graph():
        workflow = StateGraph(GenerationState)
        
        # Add existing nodes...
        workflow.add_node("designer", GameDesigner())
        workflow.add_node("architect", Architect())
        
        # Add your new node
        workflow.add_node("my_new_agent", MyNewAgent())
        
        # Define edges (flow)
        workflow.add_edge("architect", "my_new_agent") 
        workflow.add_edge("my_new_agent", "coder")
        
        # Set entry point
        workflow.set_entry_point("designer")
        
        return workflow.compile()
    ```

3.  **Update Schema** in `backend/schemas/state.py` if your agent introduces new data fields to the shared state.

4.  **Update Prompts** in `backend/agents/prompts.py` if necessary.

---

## 3. Testing

### Unit Tests (Pytest)

Run specific modules or the whole suite:

```bash
# Run all unit tests
make test-unit

# Or directly
pytest backend/tests/unit -v
```

**Coverage:**
- Validators (Quest, Dialogue, Level)
- Service logic (Billing, Workspace, MinIO)
- Agent prompt rendering
- Schema validation

### Integration Tests

Tests that require database and external services:

```bash
# Run integration tests (requires running DB/Redis containers)
make test-integration

# Or directly
pytest backend/tests/integration --cov
```

Uses `testcontainers` or connects to local Docker network services. Ensures DB transactions, Redis locking, and MinIO uploads work correctly.

### E2E Test Scenario

**Scenario**: "Create a game: platformer, pixel-art, sci-fi, 2 quests, branching dialogues, save/load"

```python
# backend/tests/e2e/test_full_pipeline.py
import pytest
import asyncio
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_e2e_platformer_generation(client, auth_token):
    """
    Full end-to-end test: Request generation, wait for completion, verify artifacts.
    """
    # 1. Submit Request
    payload = {
        "genre": "platformer",
        "style": "pixel_art",
        "setting": "sci-fi_station",
        "quest_complexity": "simple", # Expect 1-2 quests
        "dialogue_depth": "branching",
        "features": ["save_system"],
        "lore_id": None # Use default
    }
    
    response = await client.post("/api/v1/generate", json=payload, headers=auth_token)
    assert response.status_code == 200
    job_id = response.json()["job_id"]

    # 2. Poll Status (Wait for Completion)
    status = "pending"
    max_wait = 600 # 10 minutes timeout
    elapsed = 0
    
    while status in ["pending", "processing"] and elapsed < max_wait:
        await asyncio.sleep(5)
        res = await client.get(f"/api/v1/jobs/{job_id}", headers=auth_token)
        assert res.status_code == 200
        status = res.json()["status"]
        elapsed += 5

    assert status == "completed", f"Job failed: {res.json().get('error')}"

    # 3. Verify Artifacts Exist
    workspace_path = res.json()["workspace_path"]
    
    assert os.path.exists(f"{workspace_path}/main.tscn")
    assert os.path.exists(f"{workspace_path}/modules/save_system.gd")
    assert os.path.exists(f"{workspace_path}/data/quests.json")
    assert os.path.exists(f"{workspace_path}/data/dialogues.json")
    assert os.path.exists(f"{workspace_path}/assets/localization/en.json")

    # 4. Verify Content Quality
    quests = load_json(f"{workspace_path}/data/quests.json")
    assert len(quests) >= 1, "Expected at least 1 quest"
    
    dialogues = load_json(f"{workspace_path}/data/dialogues.json")
    has_branching = any(len(d.get("nodes", [])) > 2 for d in dialogues)
    assert has_branching, "Expected branching dialogues"

    # 5. Trigger Playtest (Headless Godot)
    playtest_res = await client.post(f"/api/v1/jobs/{job_id}/playtest", headers=auth_token)
    assert playtest_res.status_code == 200
    
    report = playtest_res.json()
    assert report["stability_score"] > 75, f"Low stability: {report}"
    
    # Optional: Check specific metrics if items/NPCs exist
    # assert report["metrics"].get("items_collected", 0) >= 0

    print("✅ E2E Test Passed!")
```

Run E2E tests:
```bash
make test-e2e
```

---

## 4. Deployment

### Production Docker Compose

Use `docker-compose.prod.yml` for production environments. This file optimizes for performance, security, and persistence.

```bash
docker compose -f docker-compose.prod.yml up -d
```

**Key Differences from Dev:**
- **Nginx**: Handles SSL termination (Let's Encrypt) and reverse proxying.
- **Ollama**: Uses GPU flags (`--gpus all`) for faster inference.
- **Postgres**: Tuned `shared_buffers`, `work_mem`, and WAL settings for high load.
- **Redis**: Persists AOF for durability.
- **Logs**: JSON formatted logs shipped to external ELK/Loki stack.
- **No Hot Reload**: Containers run optimized production builds.

### Worker Scaling

For high load, scale the backend workers horizontally:

```bash
# Scale backend to 5 instances
docker compose -f docker-compose.prod.yml up -d --scale backend=5
```

**Important Considerations:**
- Ensure **Redis** is configured as the broker for LangGraph state if running multiple orchestrators.
- Use **sticky sessions** in Nginx for WebSocket connections to ensure log streaming stays connected to the correct worker.
- In MVP, the `JobManager` locks jobs to specific workers via Redis distributed locks to prevent race conditions.

### Backup / Restore

**Backup:**
```bash
# Creates timestamped dump of Postgres + MinIO bucket snapshot
make backup
# Output: backups/backup_YYYY_MM_DD_HH_MM.tar.gz
```

**Restore:**
```bash
# Restore from a specific backup file
make restore FILE=backups/backup_2024_05_20_14_30.tar.gz
```

**Manual Backup Strategy:**
- **Postgres**: `pg_dump` piped to gzip, stored in S3.
- **MinIO**: `mc mirror` to backup bucket.
- **Volumes**: Tarball of `docker-volumes` directory.

### Monitoring

- **Health Endpoints**: `GET /health` checks connectivity to DB, Redis, Ollama, and MinIO. Returns 503 if any critical service is down.
- **Logs**: Structured JSON logs written to stdout/stderr, collected by Docker logging driver and shipped to Loki/ELK.
- **Metrics**: Prometheus endpoint at `/metrics` exposes:
    - Request latency histograms.
    - Queue depth (pending jobs).
    - GPU memory usage (via Ollama exporter).
    - Error rates per agent.

**Alerting Rules (Prometheus):**
- `job_failure_rate > 0.1` (10% failure rate over 5m).
- `ollama_gpu_memory_used > 0.9 * ollama_gpu_memory_total`.
- `db_connections_active > 0.8 * db_connections_max`.

---

## 5. How to Extend

### Add a New Genre to the Wizard

1.  **Frontend**: Update `frontend/data/genres.ts` with the new genre ID, label, and compatible perspectives.
2.  **Backend Schema**: Add the new genre to `GenreEnum` in `backend/schemas/generation.py`.
3.  **Prompt Engineering**: Update `backend/agents/designer/prompts.py` to include examples and specific constraints for the new genre.
4.  **Mapping Service**: Ensure `backend/services/mapping_service.py` knows which core modules correspond to this genre (e.g., "RPG" → enables `InventoryModule`, `QuestModule`; "Racing" → enables `CheckpointModule`, `LapCounterModule`).
5.  **Compatibility Matrix**: Update the frontend wizard logic to block invalid combinations (e.g., "Visual Novel" + "Isometric").

### Add a New Level Algorithm

1.  **Implement Algorithm**: Create `backend/services/level_gen/algorithms/my_algo.py`.
    - Must inherit `BaseLevelAlgorithm`.
    - Implement `generate(params: LevelParameters) -> LevelLayout`.
2.  **Register**: Add to `ALGORITHM_REGISTRY` in `backend/services/level_gen/factory.py`.
3.  **Wizard UI**: Add option to Step 4 (Level Type) in frontend with a description.
4.  **Validator**: Update `LevelLayoutValidator` if the new algorithm produces unique constraints (e.g., ensures start/end connectivity).
5.  **Coder Integration**: Ensure the Coder agent knows how to convert the new layout format into Godot scenes (may require updating `coder/templates/level_loader.gd`).

### Add a New Asset Slot

*Warning: This changes the Core Contract and affects all agents.*

1.  **Schema**: Update `AssetSlot` Literal type in `backend/schemas/assets.py` (e.g., add `"vehicle"`).
2.  **Art Director**: Update the system prompt to recognize when to use this slot and generate appropriate prompts.
3.  **Coder**: Update template logic to handle loading this slot type (e.g., instantiate `Vehicle` node).
4.  **Godot Core**: Ensure the engine has a loader/handler for this slot type (e.g., if adding "music", ensure `AudioStreamPlayer` logic exists in Core).
5.  **Validation**: Update `QA` agent to check that assets for this slot are generated and referenced correctly.

### Add a New Locale

1.  **Config**: Add language code to `SUPPORTED_LOCALES` in `backend/config.py`.
2.  **LLM Prompt**: Update `LocalizationManager` prompt to generate keys and translations for the new locale.
3.  **Frontend**: Add translation file in `frontend/public/locales/{code}.json` for UI strings (wizard buttons, errors).
4.  **Godot Core**: Ensure Godot project settings (`project.godot`) include the locale in `Internationalization` > `Translations`.
5.  **Fallback**: Verify that missing keys fall back to English (`en`) gracefully.

---

## 6. Code Style

### GDScript (Generated & Core)

- **Naming**: `snake_case` for variables/functions, `PascalCase` for classes/signals.
- **Signals**: Must prefix custom signals with `module_` (e.g., `module_quest_completed`).
- **Types**: Strict typing enforced (`var health: int = 100`). No implicit variants.
- **Guards**: No `OS.execute`, no direct filesystem writes outside `user://`.
- **Documentation**: One-line summary for public functions.

```gdscript
# ✅ Good
signal module_enemy_defeated(xp_reward: int)

func _on_enemy_hit(damage: int) -> void:
    """Reduce health by damage amount."""
    health -= damage
    if health <= 0:
        module_enemy_defeated.emit(50)

# ❌ Bad
var health = 100 # No type
func take_damage(d): # No type, vague name
    health -= d
```

### Python (Backend)

- **Async**: All I/O bound functions must be `async def`. Use `await` properly.
- **Pydantic**: Use V2 models for all data structures. Enable `model_config = ConfigDict(extra='forbid')`.
- **Type Hints**: Mandatory for function arguments and returns. Use `typing` module for generics.
- **Docstrings**: Google style for public methods and classes.
- **Error Handling**: Use specific exceptions, catch broad exceptions only at boundaries.

```python
# ✅ Good
async def generate_quest(graph: QuestGraph) -> list[QuestStage]:
    """Generates quest stages from a graph."""
    try:
        stages = await self.llm.invoke(...)
        return parse_stages(stages)
    except LLMError as e:
        raise QuestGenerationError(f"Failed to generate quest: {e}") from e

# ❌ Bad
def generate_quest(graph): # No types, sync
    try:
        # ...
    except Exception: # Broad catch
        pass
```

### Git Commit Message Convention

Format: `type(scope): description`

**Types:**
- `feat`: New feature.
- `fix`: Bug fix.
- `docs`: Documentation only.
- `style`: Formatting, missing semi-colons, etc. (no code change).
- `refactor`: Refactoring production code.
- `test`: Adding tests, refactoring test logic.
- `chore`: Updating build tasks, package manager configs, etc.

**Examples:**
```text
feat(quest): Add branching logic to quest designer
fix(coder): Resolve syntax error in inventory module
docs(readme): Update setup instructions for Windows
refactor(orch): Simplify LangGraph state machine transitions
test(e2e): Add platformer generation scenario
chore(deps): Bump next.js to version 15.1.0
```

---

## 7. Security

### AST Filters for Marketplace

Before any module is published to the Marketplace or loaded into a user's game:

1.  **Parse**: Convert GDScript to Abstract Syntax Tree (AST) using `gdtoolkit` or custom parser.
2.  **Scan**: Reject immediately if found:
    - `OS.execute`, `OS.kill`, `OS.shell_open`.
    - `HTTPClient`, `StreamPeerTCP` (unless explicitly allowed domain whitelist).
    - `DirAccess.remove_absolute` (outside `user://`).
    - Obfuscated strings (base64 blobs used as executable code).
    - Dynamic script loading (`load()` from user paths).
3.  **Perceptual Hash**: Check assets against known copyrighted material database (using `imagehash`).

```python
# Simplified AST Check Example
import ast

def is_safe_gdscript(code: str) -> bool:
    tree = gdscript_parser.parse(code)
    forbidden_calls = {"OS.execute", "HTTPClient.request"}
    
    for node in ast.walk(tree):
        if isinstance(node, ast.Call):
            func_name = get_func_name(node)
            if func_name in forbidden_calls:
                return False
    return True
```

### Docker Isolation

- **Generation Sandbox**: Each job runs in an ephemeral container with:
    - **Read-only root filesystem**: Prevents persistent malware installation.
    - **No network access**: Except to internal Ollama/MinIO/DB (via Docker network). External internet is blocked.
    - **Resource Limits**: `--cpus=2 --memory=4g` to prevent DoS.
    - **User Namespace**: Runs as non-root user (`godot:godot`).
- **User Data**: Mounted in isolated volumes per tenant (`/workspace/user_{id}`).

### What is Prohibited in Modules

Developers creating marketplace modules **cannot**:

- **Access Core Internals**: Cannot modify or reference `core/` scripts directly.
- **Bypass Signal Bus**: Cannot use `get_node("../OtherModule")` to couple modules. Must use `GlobalSignalBus`.
- **Persistent Storage**: Cannot store data outside the designated `save_data` dictionary provided by the SaveSystem.
- **Network Calls**: Cannot make HTTP requests to external servers (analytics, ads, telemetry) without explicit user consent and whitelisting.
- **Crypto Mining**: Any code resembling mining algorithms is banned.
- **Reflection**: Cannot use reflection to access private engine internals or bypass guards.

**Violations:**
- Result in immediate rejection during the QA phase.
- Lead to permanent account suspension for repeated attempts.
- Are logged and reported to security team for analysis.

---

## Appendix: Quick Command Reference

| Task | Command |
|------|---------|
| **Setup Environment** | `make setup` |
| **Start Dev Services** | `make dev` |
| **Stop All Services** | `make down` |
| **Run Unit Tests** | `make test-unit` |
| **Run Integration Tests** | `make test-integration` |
| **Run E2E Tests** | `make test-e2e` |
| **Build Production Image** | `make build` |
| **Deploy to Prod** | `make deploy` |
| **Backup Database** | `make backup` |
| **Restore Database** | `make restore FILE=...` |
| **Lint Code** | `make lint` |
| **Format Code** | `make format` |
| **View Logs** | `docker compose logs -f backend` |
| **Shell into Backend** | `docker compose exec backend bash` |
| **Pull New LLM Model** | `make ollama-pull MODEL=qwen2.5-coder:32b` |
