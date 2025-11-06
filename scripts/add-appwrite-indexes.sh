#!/bin/bash
# Add Recommended Indexes to Appwrite Collections
# Based on APPWRITE_DATABASE_VERIFICATION.md recommendations

set -eo pipefail

# Load credentials
set -a
source tools/mcp/appwrite.mcp.env
set +a

DBID="rpi_communication"
BASE="$APPWRITE_ENDPOINT"

echo "════════════════════════════════════════════════════════════════"
echo "Adding Recommended Indexes to Appwrite Collections"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Function to create index
create_index() {
  local collection=$1
  local key=$2
  local type=$3
  local order=$4
  
  echo "Creating index: $collection.$key ($type, $order)"
  
  curl -sS \
    -X POST \
    -H "X-Appwrite-Project: $APPWRITE_PROJECT_ID" \
    -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
    -H "Content-Type: application/json" \
    "$BASE/databases/$DBID/collections/$collection/indexes" \
    -d "{
      \"key\": \"idx_${key}\",
      \"type\": \"$type\",
      \"attributes\": [\"$key\"],
      \"orders\": [\"$order\"]
    }" | jq -r '.key // .message' | head -1
}

echo "1. Users Collection Indexes"
echo "────────────────────────────────────────────────────────────────"
create_index "users" "email" "unique" "ASC"
create_index "users" "role" "key" "ASC"
create_index "users" "department" "key" "ASC"
echo ""

echo "2. Books Collection Indexes"
echo "────────────────────────────────────────────────────────────────"
create_index "books" "category" "key" "ASC"
create_index "books" "status" "key" "ASC"
create_index "books" "department" "key" "ASC"
echo ""

echo "3. Book Borrows Collection Indexes"
echo "────────────────────────────────────────────────────────────────"
create_index "book_borrows" "book_id" "key" "ASC"
create_index "book_borrows" "user_id" "key" "ASC"
create_index "book_borrows" "status" "key" "ASC"
create_index "book_borrows" "due_date" "key" "ASC"
echo ""

echo "4. Approval Requests Collection Indexes"
echo "────────────────────────────────────────────────────────────────"
create_index "approval_requests" "user_id" "key" "ASC"
create_index "approval_requests" "status" "key" "ASC"
echo ""

echo "5. User Activity Collection Indexes"
echo "────────────────────────────────────────────────────────────────"
create_index "user_activity" "user_id" "key" "ASC"
create_index "user_activity" "created_at" "key" "DESC"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "Index Creation Complete"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Note: Some indexes may already exist. Check the Appwrite Console"
echo "      for the final index configuration."
echo ""
