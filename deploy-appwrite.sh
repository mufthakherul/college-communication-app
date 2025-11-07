#!/bin/bash

# Appwrite Web Dashboard Deployment Script
# This script deploys the web dashboard to Appwrite hosting

set -euo pipefail

echo "🚀 RPI Communication - Appwrite Deployment"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables from .env files if present (non-fatal)
load_dotenv() {
    local file="$1"
    if [ -f "$file" ]; then
        echo -e "${YELLOW}ℹ${NC} Loading environment from $file"
        # shellcheck disable=SC1090
        set -o allexport && source "$file" && set +o allexport || true
    fi
}

# Try loading from common locations
load_dotenv ".env"
load_dotenv ".env.local"
load_dotenv "apps/web/.env"
load_dotenv "apps/web/.env.local"
load_dotenv "tools/mcp/appwrite.mcp.env"

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

WEB_DIR="apps/web"

# Navigate to web app directory
cd "$WEB_DIR"

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

# Go back to repo root for CLI commands
cd - >/dev/null

echo ""
echo "🔐 Setting Appwrite client (API key auth) ..."

# Required/optional environment variables
: "${APPWRITE_ENDPOINT:=https://sgp.cloud.appwrite.io/v1}"
: "${APPWRITE_PROJECT_ID:=6904cfb1001e5253725b}"
SITE_ID=${APPWRITE_SITE_ID:-web-dashboard}

if [ -z "${APPWRITE_API_KEY:-}" ]; then
    echo -e "${RED}❌ APPWRITE_API_KEY not found in environment${NC}"
    echo "Export APPWRITE_API_KEY in your shell or CI environment and rerun."
    exit 1
fi

# Configure CLI client non-interactively
appwrite client \
    --endpoint "$APPWRITE_ENDPOINT" \
    --project-id "$APPWRITE_PROJECT_ID" \
    --key "$APPWRITE_API_KEY"

echo ""
echo "🚀 Creating Appwrite Site Deployment..."

set +e
appwrite sites create-deployment \
    --site-id "$SITE_ID" \
    --code "./$WEB_DIR" \
    --activate \
    --install-command "npm install" \
    --build-command "npm run build" \
    --output-directory "dist" \
    --verbose
DEPLOY_EXIT=$?
set -e

if [ $DEPLOY_EXIT -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Deployment failed. See logs above.${NC}"
    echo "Tip: Ensure APPWRITE_API_KEY has Sites write permissions and the Site ID ($SITE_ID) exists."
    exit $DEPLOY_EXIT
fi

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "📊 Deployment Summary:"
echo "  - Project: rpi-communication"
echo "  - Site: RPI Communication Dashboard"
echo "  - Platform: Appwrite"
echo "  - Build: $WEB_DIR/dist"
echo ""
echo "🌐 Your web dashboard should be live at your Appwrite hosting URL"
echo ""
