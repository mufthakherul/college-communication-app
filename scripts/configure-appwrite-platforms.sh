#!/bin/bash
# Configure Web Platform and Mobile Platforms in Appwrite
# This script adds the necessary platform configurations for the web dashboard and mobile apps

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

# Source environment variables
if [ -f "$PROJECT_ROOT/tools/mcp/appwrite.mcp.env" ]; then
    source "$PROJECT_ROOT/tools/mcp/appwrite.mcp.env"
else
    echo -e "${RED}✗ Error: appwrite.mcp.env not found${NC}"
    exit 1
fi

# Verify required environment variables
if [ -z "$APPWRITE_ENDPOINT" ] || [ -z "$APPWRITE_PROJECT_ID" ] || [ -z "$APPWRITE_API_KEY" ]; then
    echo -e "${RED}✗ Error: Missing required environment variables${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Appwrite Platform Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to create platform via REST API
create_platform() {
    local type="$1"
    local name="$2"
    local key="$3"
    local hostname="$4"
    
    echo -e "${YELLOW}Creating $name platform...${NC}"
    
    local response
    if [ "$type" = "web" ]; then
        response=$(curl -s -X POST "$APPWRITE_ENDPOINT/projects/$APPWRITE_PROJECT_ID/platforms" \
            -H "Content-Type: application/json" \
            -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
            -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
            -d "{
                \"type\": \"$type\",
                \"name\": \"$name\",
                \"key\": \"$key\",
                \"hostname\": \"$hostname\"
            }")
    else
        response=$(curl -s -X POST "$APPWRITE_ENDPOINT/projects/$APPWRITE_PROJECT_ID/platforms" \
            -H "Content-Type: application/json" \
            -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
            -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
            -d "{
                \"type\": \"$type\",
                \"name\": \"$name\",
                \"key\": \"$key\"
            }")
    fi
    
    # Check if successful
    if echo "$response" | jq -e '.$id' > /dev/null 2>&1; then
        local platform_id=$(echo "$response" | jq -r '.$id')
        echo -e "${GREEN}✓ Created $name platform (ID: $platform_id)${NC}"
        return 0
    elif echo "$response" | jq -e '.code' > /dev/null 2>&1; then
        local error_code=$(echo "$response" | jq -r '.code')
        local error_msg=$(echo "$response" | jq -r '.message')
        
        if [[ "$error_msg" == *"already exists"* ]] || [[ "$error_code" == "409" ]]; then
            echo -e "${YELLOW}⚠ $name platform already exists${NC}"
            return 0
        else
            echo -e "${RED}✗ Error creating $name: $error_msg${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Unexpected response: $response${NC}"
        return 1
    fi
}

echo -e "${YELLOW}[1/4]${NC} Creating Web Platform..."
echo ""
echo "This will allow users to login to the web dashboard."
echo "Hostnames:"
echo "  • localhost (for development)"
echo "  • *.appwrite.app (for Appwrite Sites deployment)"
echo "  • Your custom domain (if configured)"
echo ""

# Create web platform for localhost
create_platform "web" "Web Dashboard (Localhost)" "localhost" "localhost"

# Create web platform for Appwrite Sites
create_platform "web" "Web Dashboard (Appwrite Sites)" "appwrite-sites" "*.appwrite.app"

echo ""
echo -e "${YELLOW}[2/4]${NC} Creating Android Platform..."
echo ""

# Create Android platform
create_platform "android" "RPI Communication App (Android)" "com.rpi.communication"

echo ""
echo -e "${YELLOW}[3/4]${NC} Creating iOS Platform..."
echo ""

# Create iOS platform
create_platform "ios" "RPI Communication App (iOS)" "com.rpi.communication"

echo ""
echo -e "${YELLOW}[4/4]${NC} Verifying Platform Configuration..."
echo ""

# List all platforms
platforms=$(curl -s -X GET "$APPWRITE_ENDPOINT/projects/$APPWRITE_PROJECT_ID/platforms" \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY")

# Check if we got platforms back
if echo "$platforms" | jq -e '.platforms' > /dev/null 2>&1; then
    platform_count=$(echo "$platforms" | jq '.total')
    echo -e "${GREEN}✓ Total platforms configured: $platform_count${NC}"
    echo ""
    echo "Platform details:"
    echo "$platforms" | jq -r '.platforms[] | "  • \(.name) (\(.type)): \(.key // .hostname)"'
else
    # If the response doesn't have platforms key, check for error
    if echo "$platforms" | jq -e '.message' > /dev/null 2>&1; then
        error_msg=$(echo "$platforms" | jq -r '.message')
        echo -e "${YELLOW}⚠ Note: $error_msg${NC}"
        echo -e "${YELLOW}This may be expected if API key doesn't have platform read permissions${NC}"
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Platform Configuration Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Web dashboard login should now work"
echo "  2. Mobile apps can now authenticate with Appwrite"
echo "  3. Test login at: http://localhost:5173 (dev) or Appwrite Sites URL (prod)"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} If you configured a custom domain for your web app,"
echo "     add it as a separate web platform in the Appwrite Console:"
echo "     https://cloud.appwrite.io/console/project-$APPWRITE_PROJECT_ID/settings"
echo ""
