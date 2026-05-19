# Serves the release APK over HTTP so you can expose it with ngrok (phone download link).
$ErrorActionPreference = "Stop"
$apkDir = Join-Path $PSScriptRoot "..\mobile_app\build\app\outputs\flutter-apk"
$apk = Join-Path $apkDir "app-release.apk"
if (-not (Test-Path $apk)) {
    Write-Host "APK not found. Build first:" -ForegroundColor Red
    Write-Host "  cd mobile_app" -ForegroundColor Yellow
    Write-Host "  ..\flutter\bin\flutter.bat build apk --release --dart-define=API_BASE=https://YOUR-NGROK-URL" -ForegroundColor Yellow
    exit 1
}
Set-Location $apkDir
Write-Host "Serving APK at http://127.0.0.1:8080/app-release.apk" -ForegroundColor Cyan
Write-Host "In another terminal run:  ngrok http 8080" -ForegroundColor Yellow
Write-Host "Phone download link:     https://YOUR-ID.ngrok-free.app/app-release.apk" -ForegroundColor Green
python -m http.server 8080
