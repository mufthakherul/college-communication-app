#!/bin/bash
# Create Test User for Web Dashboard
# This script creates a test admin user for logging into the web dashboard

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

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Create Test User for Web Dashboard${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get user input
echo -e "${YELLOW}Enter user details:${NC}"
echo ""

read -p "Email: " EMAIL
read -sp "Password: " PASSWORD
echo ""
read -p "Name: " NAME
read -p "Role (admin/teacher/student) [admin]: " ROLE
ROLE=${ROLE:-admin}

echo ""
echo -e "${YELLOW}Creating user account...${NC}"

# Create auth user
user_response=$(curl -s -X POST "$APPWRITE_ENDPOINT/users" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    -d "{
        \"userId\": \"unique()\",
        \"email\": \"$EMAIL\",
        \"password\": \"$PASSWORD\",
        \"name\": \"$NAME\"
    }")

# Check if user creation was successful
if echo "$user_response" | jq -e '.$id' > /dev/null 2>&1; then
    USER_ID=$(echo "$user_response" | jq -r '.$id')
    echo -e "${GREEN}✓ Auth user created (ID: $USER_ID)${NC}"
    
    # Create user profile in database
    echo -e "${YELLOW}Creating user profile in database...${NC}"
    
    profile_response=$(curl -s -X POST "$APPWRITE_ENDPOINT/databases/rpi_communication/collections/users/documents" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
        -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
        -d "{
            \"documentId\": \"$USER_ID\",
            \"data\": {
                \"email\": \"$EMAIL\",
                \"name\": \"$NAME\",
                \"role\": \"$ROLE\",
                \"department\": \"Administration\",
                \"phone\": \"+8801700000000\",
                \"created_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%S.000+00:00")\"
            }
        }")
    
    if echo "$profile_response" | jq -e '.$id' > /dev/null 2>&1; then
        echo -e "${GREEN}✓ User profile created in database${NC}"
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  User Created Successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${BLUE}Login Credentials:${NC}"
        echo "  Email: $EMAIL"
        echo "  Password: [hidden]"
        echo "  Role: $ROLE"
        echo ""
        echo -e "${YELLOW}Next Steps:${NC}"
        echo "  1. Configure platforms (if not done): ./scripts/configure-platforms-guide.sh"
        echo "  2. Start web dev server: cd apps/web && npm run dev"
        echo "  3. Open browser: http://localhost:5173"
        echo "  4. Login with the credentials above"
        echo ""
    else
        echo -e "${YELLOW}⚠ User created in auth but profile creation failed${NC}"
        echo "Error: $(echo "$profile_response" | jq -r '.message')"
        echo ""
        echo "You can still login, but may need to create profile manually."
    fi
else
    echo -e "${RED}✗ Error creating user${NC}"
    error_msg=$(echo "$user_response" | jq -r '.message')
    echo "Error: $error_msg"
    echo ""
    
    if [[ "$error_msg" == *"already exists"* ]]; then
        echo -e "${YELLOW}💡 User already exists. Try logging in with existing credentials.${NC}"
    fi
fi
