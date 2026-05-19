# Public APC demo: Docker API + instructions for ngrok + web build.
# You run ngrok manually (two tunnels) — this script starts API and prints exact steps.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

Write-Host "`n=== SME Advisor — Public web demo ===" -ForegroundColor Cyan

Set-Location $root
if (-not (Test-Path (Join-Path $root ".env"))) {
    Copy-Item (Join-Path $root ".env.example") (Join-Path $root ".env")
}
Write-Host "[1] Starting API (Docker)..." -ForegroundColor Yellow
docker compose up -d --build
Start-Sleep -Seconds 8

try {
    $h = Invoke-RestMethod "http://127.0.0.1:8000/health" -TimeoutSec 10
    Write-Host "    API OK — version $($h.version)" -ForegroundColor Green
} catch {
    Write-Host "    API not ready — check: docker compose logs backend" -ForegroundColor Red
}

Write-Host @"

[2] Terminal B — expose API (copy the https URL):
    ngrok http 8000

[3] Build web pointing at that API (replace URL):
    .\scripts\build_web.ps1 -ApiBase https://YOUR-ID.ngrok-free.app

[4] Terminal C — serve web + expose it:
    .\scripts\serve_web.ps1
    # new terminal:
    ngrok http 8080

[5] Submit to judges:
    App demo:  https://....ngrok-free.app     (port 8080 tunnel)
    API docs:  https://....ngrok-free.app     (port 8000 tunnel) /docs

Tip: Click through ngrok browser warning once. Swagger alone works if web build fails.

"@ -ForegroundColor White

Set-Location $root
