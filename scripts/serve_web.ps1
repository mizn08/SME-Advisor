# Serve Flutter web build (run after build_web.ps1 or flutter build web).
$ErrorActionPreference = "Stop"
$webDir = Join-Path $PSScriptRoot "..\mobile_app\build\web"
if (-not (Test-Path $webDir)) {
    Write-Host "Web build not found. Run first:" -ForegroundColor Red
    Write-Host "  .\scripts\build_web.ps1" -ForegroundColor Yellow
    Write-Host "  # or with ngrok API:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_web.ps1 -ApiBase https://YOUR-ID.ngrok-free.app" -ForegroundColor Yellow
    exit 1
}

Set-Location $webDir
Write-Host "Serving web app at:" -ForegroundColor Cyan
Write-Host "  Local:  http://127.0.0.1:8080" -ForegroundColor Green
Write-Host "  LAN:    http://<your-Wi-Fi-IP>:8080  (phone on same Wi-Fi)" -ForegroundColor Green
Write-Host "`nPublic link (another terminal):" -ForegroundColor Yellow
Write-Host "  ngrok http 8080" -ForegroundColor White
Write-Host "  -> give judges https://....ngrok-free.app" -ForegroundColor Green
Write-Host "`nPress Ctrl+C to stop.`n" -ForegroundColor DarkGray
python -m http.server 8080 --bind 0.0.0.0
