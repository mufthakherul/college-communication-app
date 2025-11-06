#!/bin/bash

# Campus Mesh Development Setup Script (robust)
# - Always prepares the Flutter mobile app
# - Conditionally prepares Firebase functions/emulators if the 'functions/' folder exists and Firebase CLI is available

set -euo pipefail

# Move to repo root (script may be run from anywhere)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

echo "🚀 Setting up Campus Mesh development environment..."

# Helper: check if a command exists
check_tool() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Tools required for Flutter setup
echo "📋 Checking required tools..."
if ! check_tool node; then echo "❌ node is not installed"; exit 1; fi
if ! check_tool npm; then echo "❌ npm is not installed"; exit 1; fi

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

HAS_FUNCTIONS_DIR=false
if [ -d "functions" ]; then
  HAS_FUNCTIONS_DIR=true
fi

HAS_FIREBASE=false
if check_tool firebase; then
  HAS_FIREBASE=true
fi

# Flutter deps
echo "📱 Installing Flutter dependencies..."
(cd apps/mobile && "${FLUTTER_BIN}" pub get)

# Functions deps/build (optional)
if [ "$HAS_FUNCTIONS_DIR" = true ]; then
  echo "⚡ Installing Firebase Functions dependencies..."
  (cd functions && npm install)

  echo "🔨 Building TypeScript functions..."
  (cd functions && npm run build)
else
  echo "ℹ️ Skipping functions setup: 'functions/' directory not found"
fi

# Emulators (optional)
if [ "$HAS_FUNCTIONS_DIR" = true ] && [ "$HAS_FIREBASE" = true ]; then
  echo "🔥 Starting Firebase emulators..."
  firebase emulators:start --only auth,firestore,functions,storage &
  EMULATOR_PID=$!
  echo "🌐 Firebase Emulator UI: http://localhost:4000"
  echo "🛑 Press Ctrl+C to stop emulators"
  trap "kill ${EMULATOR_PID}" EXIT
  wait ${EMULATOR_PID}
else
  if [ "$HAS_FUNCTIONS_DIR" = false ]; then
    echo "ℹ️ Firebase emulators not started: functions directory missing"
  elif [ "$HAS_FIREBASE" = false ]; then
    echo "ℹ️ Firebase emulators not started: Firebase CLI not installed"
  fi
  echo "✅ Development environment setup complete!"
  echo "📱 Next: Run 'flutter run' in apps/mobile to start the app"
fi
