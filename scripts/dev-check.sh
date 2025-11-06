#!/bin/bash

# Quick development check for RPI Communication App (mobile)
# - Ensures Flutter is available
# - Runs pub get, analyze, and tests with coverage

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE_DIR="${REPO_ROOT}/apps/mobile"

# Prefer workspace Flutter if present, fallback to PATH
FLUTTER_BIN="${FLUTTER_BIN:-}"
if [ -z "${FLUTTER_BIN}" ]; then
  if [ -x "/workspaces/flutter/bin/flutter" ]; then
    FLUTTER_BIN="/workspaces/flutter/bin/flutter"
  else
    FLUTTER_BIN="flutter"
  fi
fi

if ! command -v "${FLUTTER_BIN}" >/dev/null 2>&1; then
  echo "❌ Flutter not found. Install Flutter or set FLUTTER_BIN to flutter path"
  exit 1
fi

echo "📦 Running pub get..."
(cd "${MOBILE_DIR}" && "${FLUTTER_BIN}" pub get)

echo "🔍 Analyzing code..."
# Avoid failing on info-only issues
set +e
(cd "${MOBILE_DIR}" && "${FLUTTER_BIN}" analyze --no-fatal-infos --no-fatal-warnings)
ANALYZE_EXIT=$?
set -e
if [ ${ANALYZE_EXIT} -ne 0 ]; then
  echo "⚠️  Analysis reported issues (non-fatal). Proceeding."
fi

echo "🧪 Running tests..."
(cd "${MOBILE_DIR}" && "${FLUTTER_BIN}" test --coverage)

echo "✅ Dev check complete"
