#!/usr/bin/env bash
# Build Flutter web on Render (Static Site) or Linux CI.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_BASE="${API_BASE:-https://sme-advisor-api.onrender.com}"

export FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter ${FLUTTER_VERSION}..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
  export PATH="$FLUTTER_DIR/bin:$PATH"
  flutter precache --web
fi

flutter --version
cd "$ROOT/mobile_app"
flutter pub get
echo "Building web with API_BASE=${API_BASE}"
flutter build web --release --dart-define="API_BASE=${API_BASE}"

echo "Output: $ROOT/mobile_app/build/web"
