#!/bin/bash
# Configure Permissions for Appwrite Collections
# Based on security best practices and documented schema

set -eo pipefail

# Load credentials
set -a
source tools/mcp/appwrite.mcp.env
set +a

DBID="rpi_communication"
BASE="$APPWRITE_ENDPOINT"

echo "════════════════════════════════════════════════════════════════"
echo "Configuring Collection Permissions"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Note: Appwrite permissions are configured per collection in the"
echo "      Console UI or via the REST API. This script provides the"
echo "      recommended permission configuration for each collection."
echo ""

# Function to display permissions
show_permissions() {
  local collection=$1
  shift
  local permissions=("$@")
  
  echo "Collection: $collection"
  echo "────────────────────────────────────────────────────────────────"
  for perm in "${permissions[@]}"; do
    echo "  $perm"
  done
  echo ""
}

echo "1. USERS COLLECTION"
show_permissions "users" \
  "Read:   role:admin" \
  "        user:\$userId (own profile)" \
  "Create: role:admin (manual user creation)" \
  "Update: role:admin" \
  "        user:\$userId (own profile updates)" \
  "Delete: role:admin"

echo "2. NOTICES COLLECTION"
show_permissions "notices" \
  "Read:   any (public notices where is_active=true)" \
  "        users (authenticated)" \
  "Create: label:teacher" \
  "        label:admin" \
  "Update: user:\$authorId (own notices)" \
  "        label:admin" \
  "Delete: label:admin"

echo "3. MESSAGES COLLECTION"
show_permissions "messages" \
  "Read:   user:\$senderId (sender can read)" \
  "        user:\$recipientId (recipient can read)" \
  "        label:admin" \
  "Create: users (any authenticated user)" \
  "Update: user:\$senderId (mark as read, etc.)" \
  "        user:\$recipientId (mark as read)" \
  "Delete: user:\$senderId" \
  "        label:admin"

echo "4. NOTIFICATIONS COLLECTION"
show_permissions "notifications" \
  "Read:   user:\$userId (own notifications)" \
  "        label:admin" \
  "Create: label:teacher (can notify students)" \
  "        label:admin" \
  "        users (for peer notifications)" \
  "Update: user:\$userId (mark as read)" \
  "Delete: user:\$userId (dismiss notification)" \
  "        label:admin"

echo "5. BOOKS COLLECTION"
show_permissions "books" \
  "Read:   users (all authenticated users can browse)" \
  "Create: label:teacher" \
  "        label:admin" \
  "        label:librarian" \
  "Update: label:teacher" \
  "        label:admin" \
  "        label:librarian" \
  "Delete: label:admin"

echo "6. BOOK BORROWS COLLECTION"
show_permissions "book_borrows" \
  "Read:   user:\$userId (own borrow records)" \
  "        label:teacher" \
  "        label:admin" \
  "        label:librarian" \
  "Create: users (students can request borrows)" \
  "        label:librarian (librarian issues books)" \
  "Update: label:librarian (update status, return date)" \
  "        label:admin" \
  "Delete: label:admin"

echo "7. APPROVAL REQUESTS COLLECTION"
show_permissions "approval_requests" \
  "Read:   user:\$userId (own requests)" \
  "        label:teacher (view pending)" \
  "        label:admin" \
  "Create: users (submit requests)" \
  "Update: label:teacher (approve/reject)" \
  "        label:admin" \
  "Delete: label:admin"

echo "8. USER ACTIVITY COLLECTION"
show_permissions "user_activity" \
  "Read:   user:\$userId (own activity)" \
  "        label:admin (analytics)" \
  "Create: users (auto-logged)" \
  "        system (background logging)" \
  "Update: none (immutable logs)" \
  "Delete: label:admin (cleanup old logs)"

echo "════════════════════════════════════════════════════════════════"
echo "Permission Configuration Guide"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "To apply these permissions:"
echo ""
echo "1. Go to Appwrite Console: https://cloud.appwrite.io"
echo "2. Select your project: rpi-communication"
echo "3. Navigate to: Databases > rpi_communication > [Collection]"
echo "4. Click 'Settings' tab"
echo "5. Scroll to 'Permissions' section"
echo "6. Add permissions as listed above"
echo ""
echo "Permission Types:"
echo "  - any           : Public access (no authentication)"
echo "  - users         : Any authenticated user"
echo "  - user:\$userId  : Document owner (use attribute user_id)"
echo "  - role:admin    : Users with 'admin' role"
echo "  - label:teacher : Users with 'teacher' label"
echo ""
echo "Special Variables:"
echo "  - \$userId      : Matched against user_id attribute"
echo "  - \$authorId    : Matched against author_id attribute"
echo "  - \$senderId    : Matched against sender_id attribute"
echo "  - \$recipientId : Matched against recipient_id attribute"
echo ""
echo "Security Best Practices:"
echo "  ✓ Always use least-privilege principle"
echo "  ✓ Test permissions with different user roles"
echo "  ✓ Use document-level permissions for sensitive data"
echo "  ✓ Enable 'Document Security' for fine-grained control"
echo "  ✓ Audit permissions regularly"
echo ""
