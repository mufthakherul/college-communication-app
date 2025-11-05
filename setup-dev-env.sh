#!/bin/bash
# Development Environment Setup Script
# RPI Communication App

echo "========================================="
echo "   RPI Communication App - Dev Setup"
echo "========================================="
echo ""

# Add Flutter to PATH
export PATH="$PATH:/workspaces/flutter/bin"

# Add to shell profile if not already there
if ! grep -q "export PATH=.*flutter/bin" ~/.bashrc; then
    echo 'export PATH="$PATH:/workspaces/flutter/bin"' >> ~/.bashrc
    echo "✅ Added Flutter to ~/.bashrc"
fi

# Navigate to project
cd /workspaces/college-communication-app/apps/mobile

echo ""
echo "📦 Installing Flutter dependencies..."
flutter pub get

echo ""
echo "🔍 Running code analysis..."
flutter analyze --no-fatal-infos

echo ""
echo "========================================="
echo "   ✅ Environment Setup Complete!"
echo "========================================="
echo ""
echo "📱 Flutter Version:"
flutter --version | head -3
echo ""
echo "🚀 Next Steps:"
echo "   1. Configure Appwrite credentials (already done)"
echo "   2. Optional: Add Sentry DSN and OneSignal App ID"
echo "   3. Build debug APK: flutter build apk --debug"
echo "   4. Build release APK: flutter build apk --release"
echo ""
echo "💡 Useful Commands:"
echo "   • flutter doctor          - Check environment status"
echo "   • flutter pub get         - Install dependencies"
echo "   • flutter analyze         - Check code quality"
echo "   • flutter test            - Run tests"
echo "   • flutter clean           - Clean build artifacts"
echo ""
