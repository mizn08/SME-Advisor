# Run SME Advisor on a phone on the SAME Wi-Fi as this PC.
$ErrorActionPreference = "Stop"

$ip = (
  Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.InterfaceAlias -match 'Wi-Fi|WLAN' -and $_.IPAddress -notlike '169.254*' } |
  Select-Object -First 1 -ExpandProperty IPAddress
)

if (-not $ip) {
  $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254*' } | Select-Object -First 1).IPAddress
}

$api = "http://${ip}:8000"
Write-Host "`n=== Same Wi-Fi setup ===" -ForegroundColor Cyan
Write-Host "PC API URL:  $api" -ForegroundColor Green
Write-Host "Test on phone browser: ${api}/docs`n" -ForegroundColor Yellow

Set-Location $PSScriptRoot
$flutter = Join-Path $PSScriptRoot "..\flutter\bin\flutter.bat"

Write-Host "Starting Flutter (USB phone or emulator)..." -ForegroundColor Cyan
& $flutter run --dart-define=API_BASE=$api
