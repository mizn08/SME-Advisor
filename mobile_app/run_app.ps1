# Run SME Advisor Flutter app (uses Flutter SDK next to this repo)
$ErrorActionPreference = "Stop"
$flutter = Join-Path $PSScriptRoot "..\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    Write-Error "Flutter not found at $flutter. Install or update dart.flutterSdkPath in VS Code."
}
Set-Location $PSScriptRoot
& $flutter pub get
Write-Host "Backend should be running at http://127.0.0.1:8000 (see backend\run_local.ps1)" -ForegroundColor Yellow
& $flutter run -d chrome --dart-define=API_BASE=http://127.0.0.1:8000
