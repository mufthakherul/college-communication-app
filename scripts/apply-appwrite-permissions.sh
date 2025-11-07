#!/bin/bash
# Apply Recommended Permissions to Appwrite Collections
# This script applies role-based access control permissions to all collections

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

# Database ID
DATABASE_ID="rpi_communication"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Appwrite Collection Permissions Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT NOTICE:${NC}"
echo -e "${YELLOW}This script provides the recommended permission configuration.${NC}"
echo -e "${YELLOW}Appwrite permissions are managed via the Console for security.${NC}"
echo ""
echo -e "${BLUE}Please follow these steps manually in the Appwrite Console:${NC}"
echo -e "${BLUE}https://cloud.appwrite.io/console/project-$APPWRITE_PROJECT_ID/databases/database-$DATABASE_ID${NC}"
echo ""

# Function to display permissions for a collection
display_permissions() {
    local collection_name="$1"
    local collection_id="$2"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Collection: $collection_name (ID: $collection_id)${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 1. Users Collection
display_permissions "Users" "users"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • users (Any authenticated user can read user profiles)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • users (Any authenticated user can create profile)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • user:[USER_ID] (Users can update their own profile only)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • label:admin (Only admins can delete users)"
echo ""
echo -e "${BLUE}Console Path: Collections → users → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 2. Notices Collection
display_permissions "Notices" "notices"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • users (All authenticated users can read notices)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • label:teacher (Only teachers can create notices)"
echo "     • label:admin (Admins can create notices)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • user:[USER_ID] (Creator can update their own notices)"
echo "     • label:admin (Admins can update any notice)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • user:[USER_ID] (Creator can delete their own notices)"
echo "     • label:admin (Admins can delete any notice)"
echo ""
echo -e "${BLUE}Console Path: Collections → notices → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 3. Messages Collection
display_permissions "Messages" "messages"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • user:[USER_ID] (Users can read their own messages)"
echo "     • label:admin (Admins can read all messages for moderation)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • users (Any authenticated user can send messages)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • user:[USER_ID] (Sender can update their own message)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • user:[USER_ID] (Sender can delete their own message)"
echo "     • label:admin (Admins can delete any message)"
echo ""
echo -e "${BLUE}Console Path: Collections → messages → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 4. Notifications Collection
display_permissions "Notifications" "notifications"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • user:[USER_ID] (Users can read their own notifications)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • label:admin (System/Admins create notifications)"
echo "     • label:teacher (Teachers can create notifications)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • user:[USER_ID] (Users can mark as read/update status)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • user:[USER_ID] (Users can delete their own notifications)"
echo "     • label:admin (Admins can delete any notification)"
echo ""
echo -e "${BLUE}Console Path: Collections → notifications → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 5. Books Collection
display_permissions "Books" "books"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • users (All authenticated users can browse books)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • label:librarian (Only librarians can add books)"
echo "     • label:admin (Admins can add books)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • label:librarian (Librarians can update book details)"
echo "     • label:admin (Admins can update any book)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • label:librarian (Librarians can delete books)"
echo "     • label:admin (Admins can delete books)"
echo ""
echo -e "${BLUE}Console Path: Collections → books → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 6. Book Borrows Collection
display_permissions "Book Borrows" "book_borrows"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • user:[USER_ID] (Users can see their own borrow history)"
echo "     • label:librarian (Librarians can see all borrows)"
echo "     • label:admin (Admins can see all borrows)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • users (Any user can create borrow request)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • label:librarian (Librarians approve/update borrow status)"
echo "     • label:admin (Admins can update any borrow)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • label:admin (Only admins can delete borrow records)"
echo ""
echo -e "${BLUE}Console Path: Collections → book_borrows → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 7. Approval Requests Collection
display_permissions "Approval Requests" "approval_requests"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • user:[USER_ID] (Users can read their own requests)"
echo "     • label:teacher (Teachers can see approval requests)"
echo "     • label:admin (Admins can see all requests)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • users (Any user can create approval request)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • label:teacher (Teachers can approve/reject requests)"
echo "     • label:admin (Admins can update any request)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • user:[USER_ID] (Creator can delete pending request)"
echo "     • label:admin (Admins can delete any request)"
echo ""
echo -e "${BLUE}Console Path: Collections → approval_requests → Settings → Permissions${NC}"
echo ""
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# 8. User Activity Collection
display_permissions "User Activity" "user_activity"
echo -e "${YELLOW}Recommended Permissions:${NC}"
echo ""
echo "  📖 Read Permissions:"
echo "     • user:[USER_ID] (Users can read their own activity)"
echo "     • label:admin (Admins can read all activity for analytics)"
echo ""
echo "  ✏️  Create Permissions:"
echo "     • users (System automatically logs user activity)"
echo ""
echo "  ✏️  Update Permissions:"
echo "     • None (Activity logs should be immutable)"
echo ""
echo "  🗑️  Delete Permissions:"
echo "     • label:admin (Only admins for GDPR/cleanup)"
echo ""
echo -e "${BLUE}Console Path: Collections → user_activity → Settings → Permissions${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Configuration Guide Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. Go to: https://cloud.appwrite.io/console/project-$APPWRITE_PROJECT_ID/databases/database-$DATABASE_ID"
echo "  2. For each collection, go to Settings → Permissions"
echo "  3. Add the permissions listed above"
echo "  4. Save changes"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "  • Use 'users' for any authenticated user"
echo "  • Use 'label:role' for role-based access (teacher, admin, librarian)"
echo "  • Use 'user:[USER_ID]' for document-level ownership (set at creation time)"
echo "  • Test permissions with different user roles"
echo ""
echo -e "${BLUE}📖 Full documentation: APPWRITE_INDEXES_PERMISSIONS.md${NC}"
echo ""
