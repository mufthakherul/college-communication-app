#!/bin/bash
# Platform Configuration Guide for Appwrite
# This guide explains how to manually configure platforms in the Appwrite Console

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ID="6904cfb1001e5253725b"

cat << EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${BLUE}  Appwrite Platform Configuration Guide${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}⚠️  IMPORTANT:${NC} Platforms must be configured in the Appwrite Console for
authentication to work. This is a security requirement.

${RED}🔒 Why is this needed?${NC}
Without proper platform configuration, you'll see CORS errors and login failures
because Appwrite validates the origin of requests against registered platforms.

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  STEP 1: Access Platform Settings${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

1. Open Appwrite Console:
   ${BLUE}https://cloud.appwrite.io/console/project-$PROJECT_ID/settings${NC}

2. Click on the ${YELLOW}"Platforms"${NC} tab

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  STEP 2: Add Web Platforms${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Platform 1: Localhost (Development)${NC}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Click ${BLUE}"Add Platform"${NC}
2. Select ${BLUE}"Web App"${NC}
3. Fill in:
   • Name: ${GREEN}Web Dashboard (Localhost)${NC}
   • Hostname: ${GREEN}localhost${NC}
4. Click ${BLUE}"Create"${NC}

${YELLOW}Platform 2: Appwrite Sites (Production)${NC}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Click ${BLUE}"Add Platform"${NC}
2. Select ${BLUE}"Web App"${NC}
3. Fill in:
   • Name: ${GREEN}Web Dashboard (Appwrite Sites)${NC}
   • Hostname: ${GREEN}*.appwrite.app${NC}
4. Click ${BLUE}"Create"${NC}

${BLUE}💡 Optional:${NC} If you have a custom domain:
1. Add another Web App platform
2. Hostname: ${GREEN}yourdomain.com${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  STEP 3: Add Mobile Platforms${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Platform 3: Android App${NC}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Click ${BLUE}"Add Platform"${NC}
2. Select ${BLUE}"Android"${NC}
3. Fill in:
   • Name: ${GREEN}RPI Communication App (Android)${NC}
   • Package Name: ${GREEN}com.rpi.communication${NC}
4. Click ${BLUE}"Create"${NC}

${YELLOW}Platform 4: iOS App${NC}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Click ${BLUE}"Add Platform"${NC}
2. Select ${BLUE}"iOS"${NC}
3. Fill in:
   • Name: ${GREEN}RPI Communication App (iOS)${NC}
   • Bundle ID: ${GREEN}com.rpi.communication${NC}
4. Click ${BLUE}"Create"${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  STEP 4: Verify Configuration${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

After adding all platforms, you should see:
✅ Web Dashboard (Localhost) - localhost
✅ Web Dashboard (Appwrite Sites) - *.appwrite.app
✅ RPI Communication App (Android) - com.rpi.communication
✅ RPI Communication App (iOS) - com.rpi.communication

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  STEP 5: Test Web Dashboard Login${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}For Development (localhost):${NC}
1. Start the dev server:
   ${BLUE}cd apps/web && npm run dev${NC}

2. Open browser: ${BLUE}http://localhost:5173${NC}

3. Try logging in with your Appwrite account

${YELLOW}For Production (Appwrite Sites):${NC}
1. Get your site URL from Appwrite Console:
   ${BLUE}https://cloud.appwrite.io/console/project-$PROJECT_ID/sites/site-web-dashboard${NC}

2. Open the site URL in browser

3. Try logging in

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  Troubleshooting${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${RED}❌ CORS Error / Origin not allowed${NC}
   → Check hostname matches exactly (case-sensitive)
   → For wildcards, use *.domain.com not just domain.com
   → Clear browser cache and reload

${RED}❌ "Platform not found" error${NC}
   → Make sure platform is created in Console
   → Verify hostname/bundle ID matches your app

${RED}❌ Login successful but redirects fail${NC}
   → Check callback URLs in your app match hostname
   → Verify web app is using correct project ID

${RED}❌ Mobile app can't connect${NC}
   → Ensure package name matches exactly
   → For Android: Check applicationId in build.gradle
   → For iOS: Check Bundle Identifier in Xcode

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  Additional Resources${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

📖 Appwrite Platform Docs:
   https://appwrite.io/docs/products/auth/quick-start#add-platform

📖 CORS Configuration:
   https://appwrite.io/docs/advanced/platform#cors

🔧 Your Project Console:
   https://cloud.appwrite.io/console/project-$PROJECT_ID

${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}Press Enter after you've configured the platforms in Console...${NC}
EOF

read

echo ""
echo -e "${GREEN}✓ Great! You can now test the web dashboard login.${NC}"
echo ""
echo -e "${BLUE}Quick Test Commands:${NC}"
echo ""
echo "  # Start web dev server"
echo "  cd apps/web && npm run dev"
echo ""
echo "  # Or check production deployment"
echo "  appwrite sites get --site-id web-dashboard"
echo ""
