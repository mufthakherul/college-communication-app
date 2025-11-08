#!/bin/bash
# Appwrite Database Verification Script
# Checks all collections against documented schema

set -eo pipefail

# Load credentials
set -a
source ../tools/mcp/appwrite.mcp.env
set +a

DBID="rpi_communication"
BASE="$APPWRITE_ENDPOINT"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        Appwrite Database Verification Report                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Database: $DBID"
echo "Endpoint: $BASE"
echo ""

# Fetch all collections
echo "Fetching collections..."
COLLECTIONS_JSON=$(curl -sS \
  -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
  -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
  -H "Content-Type: application/json" \
  "$BASE/databases/$DBID/collections?limit=100")

# Check for errors
ERR=$(echo "$COLLECTIONS_JSON" | jq -r '.message // empty')
if [ -n "$ERR" ]; then
  echo -e "${RED}✗ Error: $ERR${NC}"
  exit 1
fi

TOTAL=$(echo "$COLLECTIONS_JSON" | jq -r '.total // 0')
echo -e "${GREEN}✓ Found $TOTAL collections${NC}"
echo ""

# Expected collections from schema
EXPECTED_COLLECTIONS=(
  "Users:users"
  "Notices:notices"
  "Messages:messages"
  "Books:books"
  "Book Borrows:book_borrows"
  "Notifications:notifications"
  "Approval Requests:approval_requests"
  "User Activity:user_activity"
)

echo "════════════════════════════════════════════════════════════════"
echo "Collection Status Check"
echo "════════════════════════════════════════════════════════════════"

for entry in "${EXPECTED_COLLECTIONS[@]}"; do
  IFS=':' read -r NAME ID <<< "$entry"
  
  # Check if collection exists
  EXISTS=$(echo "$COLLECTIONS_JSON" | jq -r --arg name "$NAME" '.collections[] | select(.name == $name) | .name // empty')
  
  if [ -n "$EXISTS" ]; then
    echo -e "${GREEN}✓${NC} $NAME"
  else
    echo -e "${RED}✗${NC} $NAME ${YELLOW}(missing)${NC}"
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Collection Details"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Get details for each collection
echo "$COLLECTIONS_JSON" | jq -r '.collections[] | "\(.name) (\(."$id"))"' | while read -r line; do
  CNAME=$(echo "$line" | sed 's/ (.*//')
  CID=$(echo "$line" | sed 's/.*(\(.*\))/\1/')
  
  echo "Collection: $CNAME"
  echo "ID: $CID"
  
  # Fetch collection details
  DETAILS=$(curl -sS \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    "$BASE/databases/$DBID/collections/$CID")
  
  # Count attributes and indexes
  ATTRS=$(echo "$DETAILS" | jq '.attributes | length // 0')
  INDEXES=$(echo "$DETAILS" | jq '.indexes | length // 0')
  ENABLED=$(echo "$DETAILS" | jq -r '.enabled')
  
  echo "  Attributes: $ATTRS"
  echo "  Indexes: $INDEXES"
  echo "  Enabled: $ENABLED"
  
  # List attributes
  echo "  Attribute List:"
  echo "$DETAILS" | jq -r '.attributes[]? | "    - \(.key) (\(.type)\(.required | if . then ", required" else "" end))"'
  
  echo ""
done

echo "════════════════════════════════════════════════════════════════"
echo "Summary"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Total Collections: $TOTAL"
echo -e "${GREEN}✓ Database verification complete${NC}"
echo ""
echo "For detailed schema documentation, see:"
echo "  - archive_docs/APPWRITE_COLLECTIONS_SCHEMA.md"
echo "  - docs/APPWRITE_GUIDE.md"
echo ""
