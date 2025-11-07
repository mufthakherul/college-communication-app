#!/bin/bash
# Deploy Web Dashboard to Appwrite Sites
# This script builds and deploys the web dashboard to Appwrite Sites

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WEB_DIR="$PROJECT_ROOT/apps/web"
DIST_DIR="$WEB_DIR/dist"

# Appwrite configuration
APPWRITE_ENDPOINT="https://sgp.cloud.appwrite.io/v1"
APPWRITE_PROJECT_ID="6904cfb1001e5253725b"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Appwrite Sites Deployment - RPI Communication Dashboard${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Check dependencies
echo -e "${YELLOW}[1/5]${NC} Checking dependencies..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗ npm is not installed${NC}"
    exit 1
fi

if ! command -v appwrite &> /dev/null; then
    echo -e "${RED}✗ Appwrite CLI is not installed${NC}"
    echo -e "${YELLOW}Install with: npm install -g appwrite-cli${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies installed${NC}"
echo ""

# Step 2: Build web dashboard
echo -e "${YELLOW}[2/5]${NC} Building web dashboard..."
cd "$WEB_DIR"

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
fi

echo -e "${YELLOW}Building production bundle...${NC}"
npm run build

if [ ! -d "$DIST_DIR" ]; then
    echo -e "${RED}✗ Build failed - dist directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build completed successfully${NC}"
echo ""

# Step 3: Configure Appwrite CLI
echo -e "${YELLOW}[3/5]${NC} Configuring Appwrite CLI..."

# Check if already logged in
if appwrite client --endpoint "$APPWRITE_ENDPOINT" 2>/dev/null; then
    echo -e "${GREEN}✓ Appwrite CLI already configured${NC}"
else
    echo -e "${YELLOW}Please log in to Appwrite:${NC}"
    appwrite login
fi

# Set project
appwrite client \
    --endpoint "$APPWRITE_ENDPOINT" \
    --project-id "$APPWRITE_PROJECT_ID"

echo -e "${GREEN}✓ Appwrite CLI configured${NC}"
echo ""

# Step 4: Initialize site (if not exists)
echo -e "${YELLOW}[4/5]${NC} Checking site configuration..."

# Create appwrite.json if it doesn't exist
if [ ! -f "$PROJECT_ROOT/appwrite.json" ]; then
    echo -e "${YELLOW}Creating appwrite.json configuration...${NC}"
    cat > "$PROJECT_ROOT/appwrite.json" <<EOF
{
  "\$schema": "https://appwrite.io/schemas/appwrite.json",
  "projectId": "$APPWRITE_PROJECT_ID",
  "projectName": "rpi-communication",
  "sites": [
    {
      "name": "RPI Communication Dashboard",
      "outputDirectory": "apps/web/dist"
    }
  ]
}
EOF
    echo -e "${GREEN}✓ Created appwrite.json${NC}"
else
    echo -e "${GREEN}✓ appwrite.json already exists${NC}"
fi

echo ""

# Step 5: Deploy to Appwrite Sites
echo -e "${YELLOW}[5/5]${NC} Deploying to Appwrite Sites..."

cd "$PROJECT_ROOT"

# Deploy the site (using 'push' command in newer Appwrite CLI)
if appwrite push site; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ Deployment Successful!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Your web dashboard is now live!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Visit your Appwrite Console: https://cloud.appwrite.io/console/project-$APPWRITE_PROJECT_ID"
    echo -e "  2. Go to 'Sites' section to view your deployment"
    echo -e "  3. Configure custom domain (optional)"
    echo ""
else
    echo -e "${RED}✗ Deployment failed${NC}"
    echo -e "${YELLOW}Troubleshooting tips:${NC}"
    echo -e "  1. Check your Appwrite authentication: appwrite login"
    echo -e "  2. Verify project ID in appwrite.json"
    echo -e "  3. Ensure you have Sites enabled in your plan"
    exit 1
fi
