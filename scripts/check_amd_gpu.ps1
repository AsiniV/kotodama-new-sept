# =============================================================================
# AMD Ryzen AI Max 395 GPU Diagnostics for Kotodama
# =============================================================================

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "AMD Ryzen AI Max 395 (RDNA 3.5) GPU Diagnostics for Kotodama" -ForegroundColor Cyan
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------------------------------------
# 1. Check Windows AMD drivers
# -----------------------------------------------------------------------------
Write-Host "[1/5] Checking AMD GPU drivers..." -ForegroundColor Yellow
$gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*AMD*" -or $_.Name -like "*Radeon*" }
if ($gpu) {
    Write-Host "  [OK] Found GPU: $($gpu.Name)" -ForegroundColor Green
    Write-Host "  [OK] Driver version: $($gpu.DriverVersion)" -ForegroundColor Green
    Write-Host "  [OK] AdapterRAM: $([math]::Round($gpu.AdapterRAM / 1GB, 2)) GB" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] AMD GPU not found in Windows!" -ForegroundColor Red
    Write-Host "         Download drivers: https://www.amd.com/en/support" -ForegroundColor Yellow
}
Write-Host ""

# -----------------------------------------------------------------------------
# 2. Check Docker Desktop
# -----------------------------------------------------------------------------
Write-Host "[2/5] Checking Docker Desktop..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Docker Desktop is running" -ForegroundColor Green
        $wsl = $dockerInfo | Select-String "WSL"
        if ($wsl) {
            Write-Host "  [OK] WSL2 backend detected" -ForegroundColor Green
        }
    } else {
        Write-Host "  [FAIL] Docker Desktop is not running" -ForegroundColor Red
    }
} catch {
    Write-Host "  [FAIL] Docker command not available" -ForegroundColor Red
}
Write-Host ""

# -----------------------------------------------------------------------------
# 3. Check Ollama container
# -----------------------------------------------------------------------------
Write-Host "[3/5] Checking Ollama container..." -ForegroundColor Yellow
$ollama = docker ps --filter "name=kotodama-ollama" --format "{{.Status}}"
if ($ollama) {
    Write-Host "  [OK] Ollama container is running: $ollama" -ForegroundColor Green
    Write-Host "  Checking Ollama API inside container..." -ForegroundColor Yellow
    $gpuInfo = docker exec kotodama-ollama ollama ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Ollama API accessible" -ForegroundColor Green
        Write-Host "  Running models: $gpuInfo" -ForegroundColor Cyan
    } else {
        Write-Host "  [WARN] Ollama API not responding yet" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] Ollama container is not running" -ForegroundColor Red
    Write-Host "         Run: docker compose up -d ollama" -ForegroundColor Yellow
}
Write-Host ""

# -----------------------------------------------------------------------------
# 4. Check Ollama server info + installed models
# -----------------------------------------------------------------------------
Write-Host "[4/5] Checking Ollama server info and models..." -ForegroundColor Yellow
if ($ollama) {
    try {
        $serverInfo = Invoke-RestMethod -Uri "http://localhost:11434/api/version" -TimeoutSec 10
        Write-Host "  [OK] Ollama version: $($serverInfo.version)" -ForegroundColor Green

        $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 10
        Write-Host "  [OK] Installed models: $($models.models.Count)" -ForegroundColor Green
        foreach ($model in $models.models) {
            $sizeGB = [math]::Round($model.size / 1GB, 2)
            Write-Host "    - $($model.name) ($sizeGB GB)" -ForegroundColor Cyan
        }
        if ($models.models.Count -eq 0) {
            Write-Host "  [INFO] No models installed yet. Run pull_models_amd.ps1" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [WARN] Could not fetch server info: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [SKIP] Ollama not running" -ForegroundColor Yellow
}
Write-Host ""

# -----------------------------------------------------------------------------
# 5. Test GPU inference speed (only if a model is installed)
# -----------------------------------------------------------------------------
Write-Host "[5/5] Testing GPU inference speed..." -ForegroundColor Yellow
if ($ollama) {
    $models = $null
    try {
        $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 10
    } catch { }

    if ($models -and $models.models.Count -gt 0) {
        $modelName = $models.models[0].name
        Write-Host "  Sending test prompt to model: $modelName" -ForegroundColor Yellow
        $testStart = Get-Date
        try {
            $body = @{
                model = $modelName
                prompt = "Write a haiku about coding"
                stream = $false
            } | ConvertTo-Json
            $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 120

            $testEnd = Get-Date
            $elapsed = ($testEnd - $testStart).TotalSeconds

            if ($response.eval_count -and $response.eval_duration) {
                $tokensPerSec = $response.eval_count / ($response.eval_duration / 1e9)
                Write-Host "  [OK] Tokens generated: $($response.eval_count)" -ForegroundColor Green
                Write-Host "  [OK] Speed: $([math]::Round($tokensPerSec, 2)) tokens/sec" -ForegroundColor Green
                Write-Host "  [OK] Total time: $([math]::Round($elapsed, 2)) seconds" -ForegroundColor Green

                if ($tokensPerSec -gt 15) {
                    Write-Host "  [EXCELLENT] GPU acceleration is working well" -ForegroundColor Green
                } elseif ($tokensPerSec -gt 5) {
                    Write-Host "  [GOOD] Vulkan backend is active" -ForegroundColor Green
                } elseif ($tokensPerSec -gt 2) {
                    Write-Host "  [MEDIUM] Partial GPU, some CPU fallback" -ForegroundColor Yellow
                } else {
                    Write-Host "  [SLOW] CPU-only mode detected" -ForegroundColor Red
                }
            } else {
                Write-Host "  [WARN] Could not parse eval metrics" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  [FAIL] Failed to get response: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  [SKIP] No models installed. Pull models first to test speed." -ForegroundColor Yellow
    }
} else {
    Write-Host "  [SKIP] Ollama not running" -ForegroundColor Yellow
}
Write-Host ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTICS COMPLETE" -ForegroundColor Cyan
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "AMD Ryzen AI Max 395 with 64GB VRAM should achieve:" -ForegroundColor Yellow
Write-Host "  - qwen2.5:32b         : 15-25 tokens/sec (Vulkan)" -ForegroundColor Yellow
Write-Host "  - qwen2.5-coder:32b   : 15-25 tokens/sec (Vulkan)" -ForegroundColor Yellow
Write-Host "  - qwen2.5:72b (Q4)    : 5-10 tokens/sec (fits in 64GB!)" -ForegroundColor Yellow
Write-Host ""
Write-Host "If speed is below 5 tokens/sec, try:" -ForegroundColor Yellow
Write-Host "  1. Update AMD drivers from amd.com" -ForegroundColor White
Write-Host "  2. Update Docker Desktop to latest" -ForegroundColor White
Write-Host "  3. Update WSL: wsl --update" -ForegroundColor White
Write-Host "  4. Check BIOS: UMA Frame Buffer = 64GB" -ForegroundColor White
Write-Host ""