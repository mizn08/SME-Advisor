# One script to prep API + APK download for your phone.
# You still run TWO ngrok commands (or use same PC on same Wi-Fi without ngrok).
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "`n=== SME Advisor — Phone demo ===" -ForegroundColor Cyan

# 1. API
Write-Host "`n[1] Starting API (Docker)..." -ForegroundColor Yellow
Set-Location (Join-Path $root "backend")
docker compose -f (Join-Path $root "docker-compose.yml") up -d 2>$null
if (-not $?) {
    Set-Location $root
    docker compose up -d
}
Set-Location $root
Start-Sleep -Seconds 3
try {
    $h = Invoke-RestMethod "http://127.0.0.1:8000/health" -TimeoutSec 5
    Write-Host "    API OK: http://127.0.0.1:8000/docs" -ForegroundColor Green
} catch {
    Write-Host "    API not ready yet — wait and open http://127.0.0.1:8000/docs" -ForegroundColor Red
}

$apk = Join-Path $root "mobile_app\build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) {
    Write-Host "`n[!] APK missing. Build with your public API URL:" -ForegroundColor Red
    Write-Host "    cd mobile_app" -ForegroundColor Yellow
    Write-Host "    ..\flutter\bin\flutter.bat build apk --release --dart-define=API_BASE=https://YOUR-NGROK-URL" -ForegroundColor Yellow
} else {
    Write-Host "`n[2] APK ready: $apk" -ForegroundColor Green
}

Write-Host @"

[3] CREATE YOUR LINKS (two terminals)

  Terminal A — API for the app:
    ngrok http 8000
    -> https://XXXX.ngrok-free.app/docs

  Terminal B — APK download for your phone:
    cd $root
    .\scripts\serve_apk.ps1
    (new terminal) ngrok http 8080
    -> https://YYYY.ngrok-free.app/app-release.apk

  On your phone: open the APK link in Chrome -> download -> install.
  Rebuild APK if needed so API_BASE matches Terminal A ngrok URL.

  SAME Wi-Fi (no ngrok): use http://YOUR-PC-IP:8000 in APK build instead.

"@ -ForegroundColor White
