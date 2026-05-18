# Run AFTER installing Android Studio (first launch finishes SDK download)
$ErrorActionPreference = "Stop"

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
if (-not (Test-Path $sdk)) {
    Write-Host "Android SDK not found at: $sdk" -ForegroundColor Red
    Write-Host "Install Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
    Write-Host "Open it once, complete setup wizard (SDK + platform tools), then run this script again."
    exit 1
}

$flutter = Join-Path $PSScriptRoot "..\flutter\bin\flutter.bat"
& $flutter config --android-sdk $sdk

$localProps = Join-Path $PSScriptRoot "android\local.properties"
$flutterSdk = (Resolve-Path (Join-Path $PSScriptRoot "..\flutter")).Path.Replace('\', '\\')
$sdkEscaped = $sdk.Replace('\', '\\')
@"
sdk.dir=$sdkEscaped
flutter.sdk=$flutterSdk
"@ | Set-Content -Path $localProps -Encoding UTF8

Write-Host "ANDROID_HOME -> $sdk" -ForegroundColor Green
Write-Host "Wrote $localProps" -ForegroundColor Green
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  & `"$flutter`" doctor --android-licenses   # press y for all"
Write-Host "  & `"$flutter`" doctor"
Write-Host "  & `"$flutter`" build apk --release --dart-define=API_BASE=https://YOUR-NGROK-URL"
