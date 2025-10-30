#!/bin/bash

# Firebase Setup Script for RPI Communication App
# This script automates the Firebase connection process

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Firebase Setup for RPI Communication App${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found${NC}"
    echo "Please install it first:"
    echo "  npm install -g firebase-tools"
    exit 1
fi

echo -e "${GREEN}✓ Firebase CLI found${NC}"

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo -e "${YELLOW}⚠️  FlutterFire CLI not found${NC}"
    echo "Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi

echo -e "${GREEN}✓ FlutterFire CLI ready${NC}"
echo ""

# Step 1: Login to Firebase
echo -e "${BLUE}Step 1: Login to Firebase${NC}"
echo "----------------------------------------"
firebase login
echo ""

# Step 2: Select Firebase project
echo -e "${BLUE}Step 2: Select Firebase Project${NC}"
echo "----------------------------------------"
echo "If you haven't created a Firebase project yet:"
echo "1. Go to https://console.firebase.google.com"
echo "2. Click 'Add project'"
echo "3. Follow the wizard to create your project"
echo ""
echo "Now, let's connect to your Firebase project..."
firebase use --add
echo ""

# Step 3: Configure Flutter app
echo -e "${BLUE}Step 3: Configure Flutter App${NC}"
echo "----------------------------------------"
echo "This will generate Firebase configuration for your Flutter app..."
cd apps/mobile
flutterfire configure --project=$(firebase use | grep -oP "Now using alias .* for project \K.*")
cd ../..
echo ""

# Check if google-services.json was created
if [ -f "apps/mobile/android/app/google-services.json" ]; then
    echo -e "${GREEN}✓ google-services.json created${NC}"
else
    echo -e "${YELLOW}⚠️  google-services.json not found${NC}"
    echo "You may need to download it manually from Firebase Console"
fi

# Step 4: Install Function dependencies
echo -e "${BLUE}Step 4: Install Function Dependencies${NC}"
echo "----------------------------------------"
cd functions
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 5: Build Functions
echo -e "${BLUE}Step 5: Build TypeScript Functions${NC}"
echo "----------------------------------------"
npm run build
echo -e "${GREEN}✓ Functions built${NC}"
cd ..
echo ""

# Step 6: Deploy Firestore Rules
echo -e "${BLUE}Step 6: Deploy Firestore Rules${NC}"
echo "----------------------------------------"
firebase deploy --only firestore:rules
echo ""

# Step 7: Deploy Storage Rules
echo -e "${BLUE}Step 7: Deploy Storage Rules${NC}"
echo "----------------------------------------"
firebase deploy --only storage:rules
echo ""

# Step 8: Deploy Functions
echo -e "${BLUE}Step 8: Deploy Cloud Functions${NC}"
echo "----------------------------------------"
echo "This may take a few minutes..."
firebase deploy --only functions
echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Firebase Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📋 What was set up:"
echo "  ✓ Firebase project connected"
echo "  ✓ Flutter app configured"
echo "  ✓ Security rules deployed"
echo "  ✓ Cloud Functions deployed"
echo ""
echo "🎯 Next Steps:"
echo "  1. Enable Authentication in Firebase Console:"
echo "     https://console.firebase.google.com/project/_/authentication"
echo ""
echo "  2. Create Firestore Database:"
echo "     https://console.firebase.google.com/project/_/firestore"
echo ""
echo "  3. Enable Cloud Storage:"
echo "     https://console.firebase.google.com/project/_/storage"
echo ""
echo "  4. Run your Flutter app:"
echo "     cd apps/mobile && flutter run"
echo ""
echo "📖 For detailed instructions, see FIREBASE_SETUP_GUIDE.md"
echo ""
