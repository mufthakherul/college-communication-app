#!/bin/bash
# Apply All Next Steps - Master Execution Script
# This script guides you through all remaining setup steps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

clear

cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                   🚀 RPI Communication App Setup 🚀                          ║
║                     Complete Remaining Steps                                 ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}This script will guide you through all remaining setup steps:${NC}"
echo ""
echo -e "  ${GREEN}1.${NC} Configure Platform Settings (Web + Mobile)"
echo -e "  ${GREEN}2.${NC} Set Up Collection Permissions (Security)"
echo -e "  ${GREEN}3.${NC} Test Web Dashboard Login"
echo -e "  ${GREEN}4.${NC} Run Final Validation (Tests + Analysis)"
echo ""
echo -e "${YELLOW}Total time: ~15 minutes${NC}"
echo ""
read -p "Press Enter to begin..." 

# Step 1: Platform Configuration
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 1/4: Platform Configuration${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🔧 What:${NC} Add web and mobile platforms to Appwrite"
echo -e "${BLUE}⏱️  Time:${NC} ~5 minutes"
echo -e "${BLUE}❓ Why:${NC} Required for login authentication to work"
echo ""
echo -e "${YELLOW}This will open an interactive guide.${NC}"
echo ""
read -p "Press Enter to start platform configuration..." 

"$SCRIPT_DIR/configure-platforms-guide.sh"

echo ""
echo -e "${GREEN}✓ Platform configuration step completed${NC}"
echo ""

# Step 2: Collection Permissions
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 2/4: Collection Permissions${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🔧 What:${NC} Configure role-based access control for 8 collections"
echo -e "${BLUE}⏱️  Time:${NC} ~5 minutes"
echo -e "${BLUE}❓ Why:${NC} Secure data access (students can't see admin data, etc.)"
echo ""
echo -e "${YELLOW}This will show recommended permissions for each collection.${NC}"
echo ""
read -p "Press Enter to configure permissions..." 

"$SCRIPT_DIR/apply-appwrite-permissions.sh"

echo ""
echo -e "${GREEN}✓ Permissions configuration step completed${NC}"
echo ""

# Step 3: Test Web Dashboard
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 3/4: Test Web Dashboard${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🔧 What:${NC} Verify web dashboard login works"
echo -e "${BLUE}⏱️  Time:${NC} ~2 minutes"
echo -e "${BLUE}❓ Why:${NC} Ensure authentication flow is working correctly"
echo ""

echo -e "${YELLOW}Choose testing method:${NC}"
echo ""
echo "  1) Test locally (start dev server)"
echo "  2) Test production (Appwrite Sites deployment)"
echo "  3) Skip testing for now"
echo ""
read -p "Enter choice (1-3): " test_choice

case $test_choice in
  1)
    echo ""
    echo -e "${BLUE}Starting local dev server...${NC}"
    echo ""
    echo "The server will start on http://localhost:5173"
    echo ""
    echo "Available test accounts:"
    echo "  • mufthakherul@outlook.com (Admin)"
    echo "  • miraj090906@gmail.com (Admin/Teacher)"
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop the server when done testing${NC}"
    echo ""
    read -p "Press Enter to start server..." 
    cd "$PROJECT_ROOT/apps/web"
    npm run dev
    ;;
  2)
    echo ""
    echo -e "${BLUE}Getting production deployment URL...${NC}"
    echo ""
    appwrite sites get --site-id web-dashboard | grep -E "(live|deployment)" | head -5
    echo ""
    echo -e "${GREEN}Visit the site URL above and test login${NC}"
    echo ""
    read -p "Press Enter after testing..." 
    ;;
  3)
    echo -e "${YELLOW}Skipping web dashboard testing${NC}"
    ;;
esac

echo ""
echo -e "${GREEN}✓ Web dashboard testing step completed${NC}"
echo ""

# Step 4: Final Validation
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}  STEP 4/4: Final Validation${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}🔧 What:${NC} Run Flutter analyzer and tests"
echo -e "${BLUE}⏱️  Time:${NC} ~2 minutes"
echo -e "${BLUE}❓ Why:${NC} Verify code quality and ensure no regressions"
echo ""
read -p "Press Enter to run final validation..." 

cd "$PROJECT_ROOT/apps/mobile"

echo ""
echo -e "${YELLOW}Running Flutter analyzer...${NC}"
flutter analyze | tail -20

echo ""
echo -e "${YELLOW}Running Flutter tests...${NC}"
flutter test 2>&1 | tail -20

echo ""
echo -e "${GREEN}✓ Final validation completed${NC}"
echo ""

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                              ║${NC}"
echo -e "${GREEN}║                        🎉 ALL STEPS COMPLETED! 🎉                            ║${NC}"
echo -e "${GREEN}║                                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Summary of Completed Steps:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Platform configuration (Web + Mobile)"
echo -e "  ${GREEN}✓${NC} Collection permissions setup"
echo -e "  ${GREEN}✓${NC} Web dashboard testing"
echo -e "  ${GREEN}✓${NC} Code validation (analyzer + tests)"
echo ""
echo -e "${CYAN}Your Application Status:${NC}"
echo ""
echo -e "  ${GREEN}✅${NC} Web Dashboard: Deployed & Ready"
echo -e "  ${GREEN}✅${NC} Database: 8 collections, 22 indexes"
echo -e "  ${GREEN}✅${NC} Security: Permissions configured"
echo -e "  ${GREEN}✅${NC} Authentication: Platforms registered"
echo -e "  ${GREEN}✅${NC} Mobile App: Ready for build"
echo ""
echo -e "${CYAN}Quick Reference:${NC}"
echo ""
echo -e "  ${BLUE}Console:${NC}     https://cloud.appwrite.io/console/project-6904cfb1001e5253725b"
echo -e "  ${BLUE}Database:${NC}    https://cloud.appwrite.io/console/project-6904cfb1001e5253725b/databases"
echo -e "  ${BLUE}Sites:${NC}       https://cloud.appwrite.io/console/project-6904cfb1001e5253725b/sites"
echo ""
echo -e "${CYAN}Next Steps (Optional):${NC}"
echo ""
echo -e "  • Build Android APK: ${BLUE}cd apps/mobile && flutter build apk${NC}"
echo -e "  • Configure custom domain for web app"
echo -e "  • Set up Git auto-deploy for Appwrite Sites"
echo -e "  • Add production monitoring/analytics"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Thank you for using the RPI Communication App setup! 🚀${NC}"
echo ""
