# =============================================================================
# Pull Ollama models optimized for AMD Ryzen AI Max 395 (64GB VRAM)
# =============================================================================

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Pulling Ollama models for AMD Ryzen AI Max 395 (64GB VRAM)" -ForegroundColor Cyan
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

$models = @(
    @{
        name = "qwen2.5-coder:32b"
        size = "19GB"
        use = "Code generation (Coder agent)"
        priority = "REQUIRED"
    },
    @{
        name = "qwen2.5:32b"
        size = "19GB"
        use = "Design/Dialogue/Quest agents"
        priority = "REQUIRED"
    },
    @{
        name = "nomic-embed-text"
        size = "274MB"
        use = "Lore RAG embeddings"
        priority = "REQUIRED"
    },
    @{
        name = "qwen2.5:72b"
        size = "47GB"
        use = "OPTIONAL: higher quality for complex RPG games"
        priority = "OPTIONAL (fits in 64GB!)"
    }
)

$totalSize = 0

foreach ($model in $models) {
    Write-Host ""
    Write-Host "[$($model.priority)] Pulling $($model.name) (~$($model.size))" -ForegroundColor Yellow
    Write-Host "  Purpose: $($model.use)" -ForegroundColor Gray
    
    if ($model.priority -eq "REQUIRED" -or $model.priority -like "*OPTIONAL*") {
        if ($model.name -eq "qwen2.5:72b") {
            $confirm = Read-Host "  Download 72B model? (y/N)"
            if ($confirm -ne "y") {
                Write-Host "  ⏭ Skipped" -ForegroundColor Yellow
                continue
            }
        }
        
        Write-Host "  ⏬ Downloading..." -ForegroundColor Cyan
        $start = Get-Date
        docker exec kotodama-ollama ollama pull $model.name
        $end = Get-Date
        $elapsed = ($end - $start).TotalSeconds
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Downloaded in $([math]::Round($elapsed/60, 1)) minutes" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Download failed" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "All required models downloaded!" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: docker compose up -d" -ForegroundColor White
Write-Host "  2. Open: http://localhost:3000" -ForegroundColor White
Write-Host "  3. Check diagnostics: .\scripts\check_amd_gpu.ps1" -ForegroundColor White