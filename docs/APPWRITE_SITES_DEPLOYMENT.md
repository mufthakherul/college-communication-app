# Appwrite Sites Deployment Guide

## What is Appwrite Sites?

**Appwrite Sites** is a built-in static website hosting feature that allows you to deploy your web applications directly to Appwrite infrastructure with:

✅ **Automatic HTTPS/SSL** certificates  
✅ **Custom domains** or Appwrite subdomains  
✅ **CDN-powered** delivery  
✅ **Git integration** for auto-deployments  
✅ **Multiple sites** per project

---

## Current Status

- **Sites Deployed:** 0
- **Project:** rpi-communication (6904cfb1001e5253725b)
- **Endpoint:** https://sgp.cloud.appwrite.io/v1
- **Web App:** apps/web/ (Vite + TypeScript)

---

## Deployment Methods

### Method 1: Appwrite CLI (Recommended)

#### Step 1: Install Appwrite CLI

```bash
npm install -g appwrite-cli
```

#### Step 2: Login to Appwrite

```bash
appwrite login
```

You'll be prompted for:

- **Endpoint:** https://sgp.cloud.appwrite.io/v1
- **Email:** (your Appwrite account email)
- **Password:** (your password)

#### Step 3: Initialize Project

```bash
cd /workspaces/college-communication-app
appwrite init project
```

Select:

- **Project ID:** 6904cfb1001e5253725b
- **Project Name:** rpi-communication

#### Step 4: Build Web App

```bash
cd apps/web
npm install
npm run build
```

This creates `apps/web/dist/` with your built static files.

#### Step 5: Deploy Site

```bash
# From project root
appwrite deploy site \
  --site-id web-dashboard \
  --name "RPI Communication Dashboard" \
  --domain "rpi-dashboard" \
  --build-command "cd apps/web && npm run build" \
  --output-directory "apps/web/dist"
```

Or create an `appwrite.json` config file (see below).

---

### Method 2: Appwrite Console (Manual Upload)

1. **Build the app:**

   ```bash
   cd apps/web
   npm run build
   ```

2. **Go to Appwrite Console:**

   - URL: https://cloud.appwrite.io
   - Project: rpi-communication

3. **Navigate to Sites:**

   - Sidebar → **Sites**
   - Click **"Create Site"**

4. **Configure Site:**

   - **Name:** RPI Communication Dashboard
   - **Domain:** rpi-dashboard (or custom domain)
   - **Upload:** Drag `apps/web/dist/` folder

5. **Deploy:**

   - Click **"Deploy"**
   - Wait for deployment to complete

6. **Access:**
   - Your site will be available at: `https://rpi-dashboard.appwrite.io` (or your custom domain)

---

### Method 3: Git Integration (Auto-Deploy)

1. **Connect GitHub Repository:**

   - Go to Sites → Create Site
   - Select **"Connect Git Repository"**
   - Authorize Appwrite to access your repo

2. **Configure Build Settings:**

   ```
   Repository: mufthakherul/college-communication-app
   Branch: main
   Build Command: cd apps/web && npm run build
   Output Directory: apps/web/dist
   ```

3. **Auto-Deploy:**
   - Every push to `main` triggers automatic deployment
   - View build logs in Appwrite Console

---

## Configuration File (appwrite.json)

Create `appwrite.json` in project root:

```json
{
  "projectId": "6904cfb1001e5253725b",
  "projectName": "rpi-communication",
  "sites": [
    {
      "siteId": "web-dashboard",
      "name": "RPI Communication Dashboard",
      "domain": "rpi-dashboard",
      "buildCommand": "cd apps/web && npm run build",
      "outputDirectory": "apps/web/dist",
      "branch": "main"
    }
  ]
}
```

Then deploy with:

```bash
appwrite deploy site
```

---

## Custom Domain Setup

### Using Your Own Domain

1. **Add Custom Domain in Console:**

   - Sites → Your Site → Settings → Domains
   - Click **"Add Domain"**
   - Enter: `dashboard.yourdomain.com`

2. **Configure DNS:**
   Add CNAME record:

   ```
   Type: CNAME
   Name: dashboard
   Value: rpi-dashboard.appwrite.io
   TTL: 3600
   ```

3. **Verify & Enable HTTPS:**
   - Appwrite auto-provisions SSL certificate
   - Wait 5-10 minutes for propagation

---

## Environment Variables

For production builds, ensure environment variables are set:

### apps/web/.env.production

```bash
VITE_APPWRITE_ENDPOINT=https://sgp.cloud.appwrite.io/v1
VITE_APPWRITE_PROJECT_ID=6904cfb1001e5253725b
VITE_APPWRITE_DATABASE_ID=rpi_communication
```

Build command will use these automatically.

---

## Deployment Script

Create `scripts/deploy-web.sh`:

```bash
#!/bin/bash
set -eo pipefail

echo "🚀 Deploying Web Dashboard to Appwrite Sites"
echo ""

# Build
echo "📦 Building app..."
cd apps/web
npm install
npm run build
cd ../..

# Deploy
echo "🌐 Deploying to Appwrite..."
appwrite deploy site \
  --site-id web-dashboard \
  --name "RPI Communication Dashboard"

echo ""
echo "✅ Deployment complete!"
echo "🔗 Visit: https://rpi-dashboard.appwrite.io"
```

Make executable:

```bash
chmod +x scripts/deploy-web.sh
```

Run:

```bash
bash scripts/deploy-web.sh
```

---

## Mobile App Notes

**Mobile apps cannot be hosted on Appwrite Sites** (Flutter mobile apps run natively on devices).

For mobile app distribution:

### Android

- **Testing:** Build APK with `flutter build apk`
- **Production:** Publish to Google Play Store
- **Direct:** Distribute APK via Firebase App Distribution or your server

### iOS

- **Testing:** Build IPA with `flutter build ios`
- **Production:** Publish to Apple App Store
- **TestFlight:** Use for beta testing

The mobile app connects to Appwrite backend APIs regardless of how it's distributed.

---

## Comparison: Appwrite Sites vs Alternatives

| Feature                  | Appwrite Sites | Vercel | Netlify | GitHub Pages |
| ------------------------ | -------------- | ------ | ------- | ------------ |
| Static Hosting           | ✅             | ✅     | ✅      | ✅           |
| Custom Domains           | ✅             | ✅     | ✅      | ✅           |
| Auto HTTPS               | ✅             | ✅     | ✅      | ✅           |
| Git Integration          | ✅             | ✅     | ✅      | ✅           |
| CDN                      | ✅             | ✅     | ✅      | ✅           |
| SSR Support              | ❌             | ✅     | ✅      | ❌           |
| Serverless Functions     | Via Appwrite   | ✅     | ✅      | ❌           |
| Same Provider as Backend | ✅             | ❌     | ❌      | ❌           |
| Free Tier                | ✅             | ✅     | ✅      | ✅           |

**Recommendation:** Use Appwrite Sites to keep everything in one platform, or use Vercel for advanced features like SSR.

---

## Troubleshooting

### Build Fails

```bash
# Check build locally first
cd apps/web
npm run build

# Check for errors
npm run lint
```

### Deployment Timeout

- Large builds may timeout
- Optimize bundle size
- Use code splitting

### 404 Errors After Deploy

- Ensure SPA routing is configured
- Add `_redirects` file to `apps/web/public/`:
  ```
  /*    /index.html   200
  ```

### Environment Variables Not Working

- Ensure variables are prefixed with `VITE_`
- Rebuild after changing env files
- Check browser console for errors

---

## Next Steps

1. **Deploy to Appwrite Sites:**

   ```bash
   cd apps/web
   npm run build
   cd ../..
   appwrite deploy site
   ```

2. **Test the deployment:**

   - Visit: https://rpi-dashboard.appwrite.io
   - Verify login works
   - Check all features function correctly

3. **Set up auto-deploy:**

   - Connect GitHub repository
   - Configure build settings
   - Test with a commit

4. **Configure custom domain:**
   - Add domain in Appwrite Console
   - Update DNS records
   - Wait for SSL provisioning

---

## Resources

- **Appwrite Sites Docs:** https://appwrite.io/docs/products/sites
- **Appwrite CLI:** https://appwrite.io/docs/tooling/command-line
- **Your Console:** https://cloud.appwrite.io/console/project-6904cfb1001e5253725b

---

## Quick Commands Reference

```bash
# Install CLI
npm install -g appwrite-cli

# Login
appwrite login

# Build web app
cd apps/web && npm run build

# Deploy site
appwrite deploy site

# List sites
appwrite sites list

# View site details
appwrite sites get --site-id web-dashboard

# Delete site
appwrite sites delete --site-id web-dashboard
```
