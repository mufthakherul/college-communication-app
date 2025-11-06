# Web Dashboard Deployment Setup Guide

## Why Vercel Instead of Appwrite for Hosting?

### The Problem with Appwrite Storage
The previous workflow uploaded files to Appwrite Storage, but **Appwrite Storage is NOT designed for hosting websites**. It's for file storage only. While the action would succeed (files uploaded), no accessible website was created.

### Current Appwrite Capabilities (2024-2025)
According to the latest Appwrite documentation:
- ✅ Appwrite is excellent for **backend services** (database, auth, storage, functions)
- ❌ Appwrite does **NOT** have a native static site hosting feature
- ⚠️ Storage buckets cannot serve as websites with proper SPA routing
- 📚 Appwrite officially recommends using external platforms for frontend hosting

### The Solution: Hybrid Architecture
**Frontend**: Vercel (or Netlify, GitHub Pages)
**Backend**: Appwrite (database, auth, storage)

This is the **officially recommended architecture** by Appwrite.

---

## Setup Instructions

### Prerequisites
- GitHub repository (you already have this)
- Appwrite project (you already have this)
- Vercel account (free, takes 2 minutes to create)

### Step 1: Create Vercel Account (2 minutes)

1. Go to [vercel.com](https://vercel.com)
2. Click "Sign Up"
3. Choose "Continue with GitHub"
4. Authorize Vercel to access your repositories

### Step 2: Create Vercel Project (3 minutes)

1. In Vercel dashboard, click "Add New Project"
2. Import your GitHub repository: `mufthakherul/college-communication-app`
3. Configure project:
   - **Framework Preset**: Vite
   - **Root Directory**: `apps/web`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm ci`
4. Click "Deploy"

Your site will be live at: `https://your-project-name.vercel.app`

### Step 3: Get Vercel Tokens for GitHub Actions (5 minutes)

For automatic deployments from GitHub:

1. **Get Vercel Token**:
   - Vercel Dashboard → Settings → Tokens
   - Click "Create Token"
   - Name: "GitHub Actions"
   - Scope: Keep default
   - Copy the token

2. **Get Project ID**:
   - Go to your project → Settings → General
   - Find "Project ID" and copy it

3. **Get Org ID**:
   - Vercel Dashboard → Settings (top right avatar)
   - Copy your "Team/User ID"

### Step 4: Add GitHub Secrets (2 minutes)

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add these three secrets:

   | Secret Name | Value | Where to Find |
   |-------------|-------|---------------|
   | `VERCEL_TOKEN` | Your Vercel token | From Step 3.1 |
   | `VERCEL_PROJECT_ID` | Your project ID | From Step 3.2 |
   | `VERCEL_ORG_ID` | Your org/user ID | From Step 3.3 |

### Step 5: Configure CORS in Appwrite (2 minutes)

Allow your Vercel domain to access Appwrite:

1. Go to Appwrite Console: https://cloud.appwrite.io
2. Select your project
3. Settings → Platforms
4. Click "Add Platform" → "Web"
5. Add these URLs:
   - `https://your-project-name.vercel.app` (your Vercel URL)
   - `https://your-custom-domain.com` (if you add a custom domain)
   - `http://localhost:5173` (for local development)
6. Save

### Step 6: Test Deployment (1 minute)

1. Make any small change to a file in `apps/web/`
2. Commit and push to `main` branch:
   ```bash
   git add .
   git commit -m "Test Vercel deployment"
   git push
   ```
3. Watch the deployment:
   - GitHub: Actions tab → "Deploy Web Dashboard" workflow
   - Vercel: Dashboard → Your project → Deployments

---

## Automatic Deployments

Now every time you push changes to `apps/web/` on the `main` branch:

1. ✅ GitHub Actions builds your app
2. ✅ Deploys to Vercel automatically
3. ✅ Live in ~2-3 minutes
4. ✅ Previous versions retained (easy rollback)

---

## Custom Domain (Optional)

Want to use your own domain like `dashboard.yourschool.edu`?

### In Vercel:
1. Project Settings → Domains
2. Add your domain
3. Configure DNS records as instructed
4. Vercel provides free SSL automatically

### Update Appwrite CORS:
1. Add your custom domain to Appwrite Platforms
2. Done!

---

## Benefits of This Setup

### ✅ Free Forever
- Vercel: Free tier includes:
  - Unlimited deployments
  - 100GB bandwidth/month
  - Automatic HTTPS
  - Global CDN
  - No credit card required

### ✅ Production-Ready Features
- Global CDN for fast loading worldwide
- Automatic HTTPS/SSL certificates
- Perfect Lighthouse scores
- Built-in analytics
- Instant rollbacks
- Preview deployments for PRs

### ✅ Best Performance
- Edge network with 70+ locations
- Automatic image optimization
- Smart caching
- HTTP/2 and HTTP/3 support

### ✅ Zero Configuration
- Vercel auto-detects Vite
- No server management
- No DevOps knowledge needed
- Works out of the box

### ✅ Officially Recommended
This is what Appwrite recommends for frontend hosting

---

## Troubleshooting

### Deployment Fails in GitHub Actions

**Problem**: Workflow fails with "Invalid token" or similar

**Solution**:
- Check that all three secrets are added correctly
- No extra spaces in secret values
- Token hasn't expired
- Re-create token if needed

### CORS Errors

**Problem**: API requests fail with CORS errors

**Solution**:
- Add your Vercel domain to Appwrite Platforms
- Use `https://` (not `http://`)
- Clear browser cache
- Wait a few minutes for DNS propagation

### Build Fails

**Problem**: Build step fails in Vercel or GitHub Actions

**Solution**:
- Test build locally: `cd apps/web && npm run build`
- Check Node.js version (needs 18+)
- Delete `node_modules` and `package-lock.json`, then `npm install`
- Check error logs for specific TypeScript/build errors

### Site Deployed But Blank

**Problem**: Deployment succeeds but site shows blank page

**Solution**:
- Check browser console for errors (F12)
- Verify Appwrite endpoint is correct
- Check CORS settings in Appwrite
- Ensure all environment variables are set

---

## Migration from Old Setup

If you were using the old Appwrite Storage approach:

1. The old workflow uploaded files but didn't create a website
2. You can safely delete files from the `web-dashboard` Storage bucket
3. Follow steps above to set up Vercel
4. Your Appwrite backend configuration stays the same
5. No code changes needed - just better hosting!

---

## Alternative Platforms

While Vercel is recommended, you can also use:

### Netlify
- Similar features to Vercel
- Also has a GitHub Action
- Free tier comparable to Vercel
- Setup process nearly identical

### GitHub Pages
- Built into GitHub
- Free for public repos
- Slightly more complex setup
- See `DEPLOYMENT.md` for instructions

### Cloudflare Pages
- Excellent performance
- Generous free tier
- Great for global audience

All work great with Appwrite backend!

---

## Architecture Diagram

```
┌─────────────────┐
│   GitHub Repo   │
│  (Your Code)    │
└────────┬────────┘
         │
         ├──────────────────┬─────────────────┐
         │                  │                 │
         ▼                  ▼                 ▼
┌─────────────────┐  ┌──────────────┐  ┌──────────────┐
│ GitHub Actions  │  │   Vercel     │  │  Appwrite    │
│ (Build & Test)  │  │  (Frontend)  │  │  (Backend)   │
└─────────────────┘  └──────┬───────┘  └──────▲───────┘
                            │                  │
                            │    API Calls     │
                            └──────────────────┘

Users access: https://your-app.vercel.app
Frontend calls: https://sgp.cloud.appwrite.io/v1
```

---

## Summary

✅ **Frontend**: Vercel (static hosting)
✅ **Backend**: Appwrite (database, auth, storage, functions)
✅ **Deployment**: Automatic via GitHub Actions
✅ **Cost**: $0 (both have generous free tiers)
✅ **Setup Time**: ~15 minutes
✅ **Maintenance**: Zero (automatic updates)

This is the **modern, professional way** to deploy web applications with Appwrite!

---

## Need Help?

- **Vercel Issues**: [vercel.com/docs](https://vercel.com/docs)
- **Appwrite Issues**: [appwrite.io/docs](https://appwrite.io/docs)
- **GitHub Actions**: Check the Actions tab for logs
- **General Questions**: Open an issue on GitHub

---

## Next Steps

After deployment:
1. ✅ Test all features work correctly
2. ✅ Share the URL with teachers/admins
3. ✅ Consider adding a custom domain
4. ✅ Monitor usage in Vercel Analytics
5. ✅ Keep dependencies updated

Enjoy your automatically-deployed web dashboard! 🚀
