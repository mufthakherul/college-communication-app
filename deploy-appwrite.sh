#!/bin/bash

# Appwrite Web Dashboard Deployment Script
# This script deploys the web dashboard to Appwrite hosting

set -e

echo "🚀 RPI Communication - Appwrite Deployment"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo -e "${RED}❌ Appwrite CLI is not installed${NC}"
    echo "Install it with: npm install -g appwrite-cli"
    exit 1
fi

echo -e "${GREEN}✓${NC} Appwrite CLI found"

# Check if we're in the right directory
if [ ! -f "appwrite.json" ]; then
    echo -e "${RED}❌ appwrite.json not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found appwrite.json"

# Navigate to web app directory
cd apps/web

echo ""
echo "📦 Installing dependencies..."
npm install

echo ""
echo "🔨 Building the application..."
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build failed - dist folder not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Build completed successfully"

# Go back to root
cd ../..

echo ""
echo "🚀 Deploying to Appwrite..."
appwrite push sites

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "📊 Deployment Summary:"
echo "  - Project: rpi-communication"
echo "  - Site: RPI Communication Dashboard"
echo "  - Platform: Appwrite"
echo "  - Build: apps/web/dist"
echo ""
echo "🌐 Your web dashboard should be live at your Appwrite hosting URL"
echo ""
