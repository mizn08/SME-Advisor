# ── SME Advisor — Web Demo for Phone (same Wi-Fi) ──
# Starts the FastAPI backend + serves the Flutter web build on your LAN IP.
# Open the URL shown on your phone browser!
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

# ── Find your Wi-Fi LAN IP ──
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.InterfaceAlias -match 'Wi-Fi' -and $_.PrefixOrigin -ne 'WellKnown' } |
       Select-Object -First 1).IPAddress
if (-not $ip) {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.PrefixOrigin -eq 'Dhcp' } |
           Select-Object -First 1).IPAddress
}
if (-not $ip) { $ip = "127.0.0.1" }

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SME Advisor — Web Demo (Phone)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n  Your LAN IP: $ip" -ForegroundColor Yellow

# ── 1. Start FastAPI backend (SQLite mode, bound to 0.0.0.0) ──
Write-Host "`n[1/2] Starting API server on 0.0.0.0:8000 ..." -ForegroundColor Yellow
$backendDir = Join-Path $root "backend"
$env:DATABASE_URL = "sqlite:///./bnpl_local.db"
$env:PYTHONPATH = "."
$env:ML_MODELS_DIR = "app/ml_models"

$apiJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location $dir
    $env:DATABASE_URL = "sqlite:///./bnpl_local.db"
    $env:PYTHONPATH = "."
    $env:ML_MODELS_DIR = "app/ml_models"
    python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
} -ArgumentList $backendDir

Start-Sleep -Seconds 3
Write-Host "  API: http://${ip}:8000/docs" -ForegroundColor Green

# ── 2. Serve Flutter web build (Python http.server on 0.0.0.0:8080) ──
$webDir = Join-Path $root "mobile_app\build\web"
if (-not (Test-Path $webDir)) {
    Write-Host "`n[!] Flutter web build not found at $webDir" -ForegroundColor Red
    Write-Host "    Run:  cd mobile_app && ..\flutter\bin\flutter.bat build web --release" -ForegroundColor Yellow
    Stop-Job $apiJob; Remove-Job $apiJob
    exit 1
}

Write-Host "[2/2] Serving Flutter web on 0.0.0.0:8080 ..." -ForegroundColor Yellow

$webJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location $dir
    python -m http.server 8080 --bind 0.0.0.0
} -ArgumentList $webDir

Start-Sleep -Seconds 2

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  DEMO READY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n  Open this URL on your phone browser:" -ForegroundColor White
Write-Host "  >>> http://${ip}:8080 <<<" -ForegroundColor Cyan
Write-Host "`n  API Swagger docs:" -ForegroundColor White
Write-Host "  >>> http://${ip}:8000/docs <<<" -ForegroundColor DarkGray
Write-Host "`n  Press Ctrl+C to stop both servers." -ForegroundColor DarkGray
Write-Host "========================================`n" -ForegroundColor Green

# ── Keep alive & pipe logs ──
try {
    while ($true) {
        Receive-Job $apiJob 2>&1 | Write-Host
        Receive-Job $webJob 2>&1 | Write-Host
        Start-Sleep -Seconds 2
    }
} finally {
    Write-Host "`nStopping servers..." -ForegroundColor Yellow
    Stop-Job $apiJob, $webJob -ErrorAction SilentlyContinue
    Remove-Job $apiJob, $webJob -Force -ErrorAction SilentlyContinue
    Write-Host "Done." -ForegroundColor Green
}
