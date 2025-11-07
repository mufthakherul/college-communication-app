#!/bin/bash

# RPI Echo System Web Deployment Script
# Deploys the web application to Appwrite Storage/Hosting

set -e  # Exit on error

echo "🚀 Starting RPI Echo System Web Deployment"
echo "=========================================="

# Step 1: Clean previous builds
echo "📦 Step 1: Cleaning previous builds..."
cd /workspaces/college-communication-app/apps/web
rm -rf dist
echo "✅ Clean complete"

# Step 2: Build the application
echo ""
echo "🔨 Step 2: Building production bundle..."
npm run build
echo "✅ Build complete"

# Step 3: Check build size
echo ""
echo "📊 Step 3: Build summary..."
BUILD_SIZE=$(du -sh dist | cut -f1)
echo "Total build size: $BUILD_SIZE"
echo "Files in dist:"
ls -lh dist/

# Step 4: Deploy to Appwrite (if hosting is configured)
echo ""
echo "📤 Step 4: Deployment options..."
echo ""
echo "Your build is ready in: /workspaces/college-communication-app/apps/web/dist"
echo ""
echo "To deploy to Appwrite, you have several options:"
echo ""
echo "Option 1: Use Appwrite Storage"
echo "  - Upload the dist folder to Appwrite Storage"
echo "  - Serve as static files"
echo ""
echo "Option 2: Use a traditional web server"
echo "  - Upload to Nginx/Apache"
echo "  - Point to dist/index.html"
echo ""
echo "Option 3: Use Vercel/Netlify"
echo "  - Connect your GitHub repo"
echo "  - Set build command: npm run build"
echo "  - Set publish directory: dist"
echo ""
echo "=========================================="
echo "✅ Deployment preparation complete!"
echo ""
echo "Next steps:"
echo "1. Test the build locally: cd dist && python3 -m http.server 8080"
echo "2. Choose a deployment platform"
echo "3. Upload the dist folder"
echo ""
