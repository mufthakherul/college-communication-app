#!/bin/bash

# Campus Mesh Development Setup Script
# This script sets up the development environment for Campus Mesh

set -e

echo "🚀 Setting up Campus Mesh development environment..."

# Check if required tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    fi
}

echo "📋 Checking required tools..."
check_tool "node"
check_tool "npm"
check_tool "flutter"
check_tool "firebase"

# Install Flutter dependencies
echo "📱 Installing Flutter dependencies..."
cd apps/mobile
flutter pub get
cd ../..

# Install Firebase Functions dependencies
echo "⚡ Installing Firebase Functions dependencies..."
cd functions
npm install
cd ..

# Build TypeScript
echo "🔨 Building TypeScript functions..."
cd functions
npm run build
cd ..

# Start Firebase emulators
echo "🔥 Starting Firebase emulators..."
firebase emulators:start --only auth,firestore,functions,storage &
EMULATOR_PID=$!

echo "✅ Development environment setup complete!"
echo "🌐 Firebase Emulator UI: http://localhost:4000"
echo "📱 Run 'flutter run' in apps/mobile to start the mobile app"
echo "🛑 Press Ctrl+C to stop emulators"

# Keep script running
trap "kill $EMULATOR_PID" EXIT
wait $EMULATOR_PID