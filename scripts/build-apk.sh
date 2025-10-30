#!/bin/bash

# Build APK Script for RGPI Communication App
# This script builds both debug and release APK files

set -e

echo "🚀 RGPI Communication App - APK Builder"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"
flutter --version
echo ""

# Navigate to mobile app directory
cd "$(dirname "$0")/../apps/mobile"

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "🔍 Running Flutter analyzer..."
flutter analyze || echo -e "${YELLOW}⚠️  Warning: Analyzer found some issues${NC}"

echo ""
echo "🔨 Building Debug APK..."
flutter build apk --debug
DEBUG_APK="build/app/outputs/flutter-apk/app-debug.apk"

echo ""
echo "🔨 Building Release APK..."
flutter build apk --release
RELEASE_APK="build/app/outputs/flutter-apk/app-release.apk"

echo ""
echo "✨ Organizing output files..."
mkdir -p ../../build-output
cp "$DEBUG_APK" "../../build-output/rgpi-communication-debug.apk"
cp "$RELEASE_APK" "../../build-output/rgpi-communication-release.apk"

echo ""
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo "📱 APK files are located at:"
echo "   Debug:   $(pwd)/../../build-output/rgpi-communication-debug.apk"
echo "   Release: $(pwd)/../../build-output/rgpi-communication-release.apk"
echo ""

# Show file sizes
echo "📊 APK Sizes:"
ls -lh ../../build-output/*.apk | awk '{print "   " $9 " - " $5}'

echo ""
echo "📤 Next steps:"
echo "   1. Transfer APK to your Android device"
echo "   2. Enable 'Install from Unknown Sources' in device settings"
echo "   3. Open the APK file to install"
echo ""
echo "🎓 For Rangpur Government Polytechnic Institute"
echo "   Website: https://rangpur.polytech.gov.bd"
