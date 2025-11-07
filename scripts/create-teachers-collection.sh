#!/bin/bash
# Create Teachers Collection in Appwrite
# This script creates a dedicated teachers collection for the web dashboard

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f "tools/mcp/appwrite.mcp.env" ]; then
    export $(grep -v '^#' tools/mcp/appwrite.mcp.env | xargs)
else
    echo -e "${RED}Error: tools/mcp/appwrite.mcp.env not found${NC}"
    exit 1
fi

APPWRITE_ENDPOINT="${APPWRITE_ENDPOINT:-https://sgp.cloud.appwrite.io/v1}"
APPWRITE_PROJECT_ID="${APPWRITE_PROJECT_ID:-6904cfb1001e5253725b}"
DATABASE_ID="rpi_communication"
COLLECTION_ID="teachers"

clear

cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                   👨‍🏫 Create Teachers Collection 👩‍🏫                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}This script will create a dedicated teachers collection in Appwrite${NC}"
echo ""
echo -e "${BLUE}Database:${NC} $DATABASE_ID"
echo -e "${BLUE}Collection:${NC} $COLLECTION_ID"
echo -e "${BLUE}Endpoint:${NC} $APPWRITE_ENDPOINT"
echo ""
echo -e "${YELLOW}The collection will include:${NC}"
echo -e "  • 17 attributes (user_id, email, full_name, department, etc.)"
echo -e "  • 5 indexes (email, user_id, department, is_active, created_at)"
echo -e "  • Proper permissions (read: any, create/update/delete: role-based)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..." 

# Function to check if collection exists
check_collection() {
    echo -e "${YELLOW}Checking if collection already exists...${NC}"
    
    response=$(curl -s -X GET \
        "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
        -H "X-Appwrite-Key: $APPWRITE_API_KEY")
    
    if echo "$response" | grep -q "\"name\""; then
        echo -e "${YELLOW}⚠️  Collection '$COLLECTION_ID' already exists!${NC}"
        echo ""
        echo "Options:"
        echo "  1) Delete and recreate (⚠️  WARNING: This will delete all data!)"
        echo "  2) Skip creation (keep existing collection)"
        echo "  3) Cancel"
        echo ""
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                echo -e "${RED}Deleting existing collection...${NC}"
                curl -s -X DELETE \
                    "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID" \
                    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
                    -H "X-Appwrite-Key: $APPWRITE_API_KEY" > /dev/null
                echo -e "${GREEN}✓ Collection deleted${NC}"
                return 0
                ;;
            2)
                echo -e "${YELLOW}Skipping collection creation${NC}"
                exit 0
                ;;
            3)
                echo -e "${BLUE}Cancelled${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
    fi
    
    return 0
}

# Step 1: Check/Create Collection
check_collection

echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 1/3: Create Collection${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Creating 'teachers' collection...${NC}"

collection_response=$(curl -s -X POST \
    "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    -d "{
        \"collectionId\": \"$COLLECTION_ID\",
        \"name\": \"Teachers\",
        \"permissions\": [
            \"read(\\\"any\\\")\",
            \"create(\\\"label:admin\\\")\",
            \"update(\\\"label:admin\\\")\",
            \"delete(\\\"label:admin\\\")\"
        ],
        \"documentSecurity\": true
    }")

if echo "$collection_response" | grep -q "\"name\""; then
    echo -e "${GREEN}✓ Collection created successfully${NC}"
else
    echo -e "${RED}✗ Failed to create collection${NC}"
    echo "$collection_response"
    exit 1
fi

# Step 2: Create Attributes
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 2/3: Create Attributes${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Helper function to create attribute
create_attribute() {
    local key=$1
    local type=$2
    local size=$3
    local required=$4
    local default=$5
    local array=$6
    
    echo -e "${YELLOW}Creating attribute: $key ($type)${NC}"
    
    local data="{\"key\": \"$key\", \"size\": $size, \"required\": $required"
    
    if [ "$array" = "true" ]; then
        data="$data, \"array\": true"
    fi
    
    if [ -n "$default" ] && [ "$default" != "null" ]; then
        data="$data, \"default\": $default"
    fi
    
    data="$data}"
    
    response=$(curl -s -X POST \
        "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/$type" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
        -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
        -d "$data")
    
    if echo "$response" | grep -q "\"key\""; then
        echo -e "${GREEN}  ✓ $key created${NC}"
    else
        echo -e "${RED}  ✗ Failed to create $key${NC}"
        echo "  $response"
    fi
    
    # Wait to avoid rate limits
    sleep 1
}

# Create string attributes
create_attribute "user_id" "string" 255 true "null" false
create_attribute "email" "email" 255 true "null" false
create_attribute "full_name" "string" 255 true "null" false
create_attribute "employee_id" "string" 50 false "null" false
create_attribute "department" "string" 100 true "null" false
create_attribute "designation" "string" 100 false "null" false
create_attribute "subjects" "string" 500 false "[]" true
create_attribute "qualification" "string" 255 false "null" false
create_attribute "specialization" "string" 255 false "null" false
create_attribute "phone_number" "string" 20 false "null" false
create_attribute "office_room" "string" 50 false "null" false
create_attribute "office_hours" "string" 255 false "null" false
create_attribute "photo_url" "url" 2000 false "null" false
create_attribute "bio" "string" 1000 false "null" false

# Create boolean attribute
echo -e "${YELLOW}Creating attribute: is_active (boolean)${NC}"
response=$(curl -s -X POST \
    "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/boolean" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    -d '{"key": "is_active", "required": true, "default": true}')

if echo "$response" | grep -q "\"key\""; then
    echo -e "${GREEN}  ✓ is_active created${NC}"
else
    echo -e "${RED}  ✗ Failed to create is_active${NC}"
fi

sleep 1

# Create datetime attributes
for attr in "joining_date" "created_at" "updated_at"; do
    echo -e "${YELLOW}Creating attribute: $attr (datetime)${NC}"
    
    required="false"
    default="null"
    if [ "$attr" = "created_at" ]; then
        required="true"
    fi
    
    response=$(curl -s -X POST \
        "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/datetime" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
        -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
        -d "{\"key\": \"$attr\", \"required\": $required}")
    
    if echo "$response" | grep -q "\"key\""; then
        echo -e "${GREEN}  ✓ $attr created${NC}"
    else
        echo -e "${RED}  ✗ Failed to create $attr${NC}"
    fi
    
    sleep 1
done

echo ""
echo -e "${YELLOW}Waiting for attributes to be available (30 seconds)...${NC}"
sleep 30

# Step 3: Create Indexes
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 3/3: Create Indexes${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Helper function to create index
create_index() {
    local key=$1
    local type=$2
    local attributes=$3
    local orders=$4
    
    echo -e "${YELLOW}Creating index: $key${NC}"
    
    response=$(curl -s -X POST \
        "$APPWRITE_ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/indexes" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
        -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
        -d "{
            \"key\": \"$key\",
            \"type\": \"$type\",
            \"attributes\": $attributes,
            \"orders\": $orders
        }")
    
    if echo "$response" | grep -q "\"key\""; then
        echo -e "${GREEN}  ✓ Index $key created${NC}"
    else
        echo -e "${RED}  ✗ Failed to create index $key${NC}"
        echo "  $response"
    fi
    
    sleep 2
}

# Create indexes
create_index "email_unique" "unique" "[\"email\"]" "[\"ASC\"]"
create_index "user_id_idx" "key" "[\"user_id\"]" "[\"ASC\"]"
create_index "department_idx" "key" "[\"department\"]" "[\"ASC\"]"
create_index "is_active_idx" "key" "[\"is_active\"]" "[\"ASC\"]"
create_index "created_at_idx" "key" "[\"created_at\"]" "[\"DESC\"]"

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                              ║${NC}"
echo -e "${GREEN}║                    ✅ Teachers Collection Created! ✅                         ║${NC}"
echo -e "${GREEN}║                                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Collection Details:${NC}"
echo ""
echo -e "  ${BLUE}Database:${NC}    $DATABASE_ID"
echo -e "  ${BLUE}Collection:${NC}  $COLLECTION_ID"
echo -e "  ${BLUE}Attributes:${NC}  17 fields"
echo -e "  ${BLUE}Indexes:${NC}     5 indexes"
echo ""
echo -e "${CYAN}Created Attributes:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} user_id (string, required)"
echo -e "  ${GREEN}✓${NC} email (email, required, unique)"
echo -e "  ${GREEN}✓${NC} full_name (string, required)"
echo -e "  ${GREEN}✓${NC} employee_id (string)"
echo -e "  ${GREEN}✓${NC} department (string, required, indexed)"
echo -e "  ${GREEN}✓${NC} designation (string)"
echo -e "  ${GREEN}✓${NC} subjects (string array)"
echo -e "  ${GREEN}✓${NC} qualification (string)"
echo -e "  ${GREEN}✓${NC} specialization (string)"
echo -e "  ${GREEN}✓${NC} phone_number (string)"
echo -e "  ${GREEN}✓${NC} office_room (string)"
echo -e "  ${GREEN}✓${NC} office_hours (string)"
echo -e "  ${GREEN}✓${NC} joining_date (datetime)"
echo -e "  ${GREEN}✓${NC} photo_url (url)"
echo -e "  ${GREEN}✓${NC} bio (string)"
echo -e "  ${GREEN}✓${NC} is_active (boolean, indexed)"
echo -e "  ${GREEN}✓${NC} created_at (datetime, indexed)"
echo -e "  ${GREEN}✓${NC} updated_at (datetime)"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo ""
echo -e "  1. ${BLUE}Verify in Console:${NC} https://cloud.appwrite.io/console/project-$APPWRITE_PROJECT_ID/databases/database-$DATABASE_ID"
echo -e "  2. ${BLUE}Create Service:${NC} apps/web/src/services/teacher.service.ts"
echo -e "  3. ${BLUE}Build UI:${NC} apps/web/src/pages/TeachersPage.tsx"
echo -e "  4. ${BLUE}Test:${NC} Add sample teachers through web dashboard"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
