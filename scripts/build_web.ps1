# Build Flutter web for demo. Pass your public API URL when using ngrok.
param(
    [string]$ApiBase = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$flutter = Join-Path $root "flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    $flutter = "flutter"
}

$mobile = Join-Path $root "mobile_app"
Set-Location $mobile

$args = @("build", "web", "--release")
if ($ApiBase) {
    Write-Host "API_BASE = $ApiBase" -ForegroundColor Cyan
    $args += @("--dart-define=API_BASE=$ApiBase")
} else {
    Write-Host "No API_BASE set — web will use same host:8000 as the page (OK on LAN)." -ForegroundColor Yellow
}

& $flutter @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`nWeb build ready: mobile_app\build\web" -ForegroundColor Green
