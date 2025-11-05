# ⚠️ DEPRECATED - This Guide is Outdated

## ❌ The Problem

This guide describes deploying to **Appwrite Storage buckets**, but this approach **DOES NOT WORK** for hosting websites.

**Why it fails:**
- Appwrite Storage buckets are for **file storage**, not website hosting
- Files upload successfully (action succeeds) but **no accessible website is created**
- No proper SPA routing support
- According to latest Appwrite docs, they don't have native static site hosting

## ✅ The Correct Solution

**Frontend Hosting**: Vercel, Netlify, or similar platforms
**Backend**: Appwrite (database, auth, storage, functions)

This is the **officially recommended architecture** by Appwrite.

### 📖 Use the New Guide Instead

**➡️ [DEPLOYMENT_SETUP.md](DEPLOYMENT_SETUP.md)** - Complete, working deployment guide

**What you'll get:**
- Automatic deployments via GitHub Actions
- Actually working website (not just uploaded files)
- Free hosting forever
- Global CDN, HTTPS, custom domains
- Setup time: 15 minutes

---

# Old Guide Content (For Reference Only)

## Overview (DOES NOT WORK AS DESCRIBED)

❌ **Does not create accessible website** - Files upload but cannot be accessed as a website
❌ **No SPA routing** - Storage buckets can't handle React Router
❌ **Not officially supported** - Appwrite doesn't recommend this approach

## How It Works (BUT DOESN'T WORK)

The old GitHub Actions workflow:
1. Builds your React app
2. Connects to your Appwrite project using API key
3. Uploads files to Appwrite Storage bucket ✅ (This works)
4. **PROBLEM**: Files in Storage bucket ≠ Hosted website ❌

Storage buckets store files, they don't serve websites with proper routing!

---

## Setup Guide (5 Minutes)

### Step 1: Create Appwrite API Key

1. **Go to Appwrite Console**: https://cloud.appwrite.io
2. **Open your project** (the same one used by mobile app)
3. **Navigate to** Settings → API Keys
4. **Click** "Create API Key"
5. **Configure the key**:
   - **Name**: `GitHub Actions Deploy`
   - **Expiration**: Never (or set long expiration)
   - **Scopes**: Enable these permissions:
     - ✅ `storage.read`
     - ✅ `storage.write`
     - ✅ `buckets.read`
     - ✅ `buckets.write`
     - ✅ `files.read`
     - ✅ `files.write`
6. **Copy the API key** (starts with a long string like `851a5c0e7f8b9c2d...`)
   - ⚠️ Save it securely - you won't see it again!

### Step 2: Add Secrets to GitHub

1. **Go to your GitHub repository**
2. **Click** Settings → Secrets and variables → Actions
3. **Click** "New repository secret"
4. **Add these 3 secrets**:

   | Secret Name | Value | Where to Find |
   |-------------|-------|---------------|
   | `APPWRITE_API_KEY` | Your API key | From Step 1 above |
   | `APPWRITE_PROJECT_ID` | `6904cfb1001e5253725b` | Your project ID (in Appwrite Console) |
   | `APPWRITE_ENDPOINT` | `https://sgp.cloud.appwrite.io/v1` | Appwrite Cloud endpoint |

### Step 3: Create Storage Bucket (One-Time)

You need to create a bucket in Appwrite to store your web files:

1. **Go to Appwrite Console** → Storage
2. **Click** "Create Bucket"
3. **Configure**:
   - **Bucket ID**: `web-dashboard` (must match workflow)
   - **Name**: `Web Dashboard`
   - **Permissions**: 
     - Read: `Any`
     - Write: Keep restricted (only API key can write)
   - **File Security**: Disable
   - **Maximum File Size**: 10MB
   - **Enabled**: Yes
4. **Click** "Create"

### Step 4: Done! Test It

1. **Make a small change** to any file in `apps/web/`
2. **Commit and push** to `main` branch:
   ```bash
   git add .
   git commit -m "Test auto-deploy to Appwrite"
   git push origin main
   ```
3. **Watch deployment**:
   - Go to GitHub → Actions tab
   - See "Deploy Web Dashboard to Appwrite" running
   - Wait ~2 minutes for completion

4. **Access your site**:
   - Go to Appwrite Console → Storage → web-dashboard bucket
   - Find `index.html` file
   - Click to get public URL
   - Or configure custom domain (see below)

---

## Accessing Your Deployed Site

### Option 1: Direct File Access

After deployment, your files are in Appwrite Storage:

1. **Appwrite Console** → Storage → `web-dashboard` bucket
2. **Click** on `index.html`
3. **Copy** the file URL (public access enabled)
4. **Access** at: `https://sgp.cloud.appwrite.io/v1/storage/buckets/web-dashboard/files/{file-id}/view`

### Option 2: Configure Custom Domain (Recommended)

Make your dashboard accessible at a nice URL:

1. **Appwrite Console** → Settings → Domains
2. **Add Custom Domain**:
   - Domain: `dashboard.yourschool.edu` (or any domain you own)
   - Point to bucket: `web-dashboard`
3. **Configure DNS**:
   - Add CNAME record as instructed by Appwrite
   - Wait for DNS propagation (24-48 hours)
4. **SSL Certificate**: Appwrite provides automatically

### Option 3: Use Appwrite Functions (Advanced)

For better routing and SPA support:

1. Create an Appwrite Function
2. Serve files from the storage bucket
3. Handle SPA routing (all routes → index.html)
4. Deploy function via CLI or GitHub Actions

---

## Monitoring Deployments

### Check Deployment Status

**In GitHub Actions:**
1. Repository → **Actions** tab
2. Click "Deploy Web Dashboard to Appwrite"
3. View all deployment runs
4. Green checkmark = success ✅
5. Red X = failed ❌ (check logs)

### View Deployment Logs

1. **Click** any workflow run
2. **Expand** "Deploy to Appwrite" step
3. **See** build output and deployment details
4. **Check** for errors if deployment fails

### Verify Files in Appwrite

1. **Appwrite Console** → Storage → `web-dashboard`
2. **See** all uploaded files
3. **Check** upload timestamp
4. **Test** by accessing files

---

## Workflow Details

The workflow file (`.github/workflows/deploy-web-dashboard.yml`) performs these steps:

```yaml
1. Trigger on push to main (when apps/web/ files change)
2. Checkout code from GitHub
3. Setup Node.js 20
4. Install dependencies (npm ci)
5. Build React app (npm run build)
6. Install Appwrite CLI
7. Connect to Appwrite using API key
8. Create/verify storage bucket exists
9. Upload dist/ files to Appwrite Storage
10. Save build artifacts for 7 days
```

---

## Troubleshooting

### Deployment Fails: Invalid API Key

**Problem**: "Invalid API key" error in logs

**Solution**:
- ✅ Check API key is copied correctly (no extra spaces)
- ✅ Verify key has correct permissions (storage.write, etc.)
- ✅ Ensure key hasn't expired
- ✅ Re-create key if necessary

### Bucket Not Found

**Problem**: "Bucket 'web-dashboard' not found"

**Solution**:
- ✅ Create bucket manually in Appwrite Console
- ✅ Use exact ID: `web-dashboard`
- ✅ Enable public read access
- ✅ Set file security to false

### Files Upload But Not Accessible

**Problem**: Files uploaded but 404 when accessing

**Solution**:
- ✅ Check bucket permissions (read: "any")
- ✅ Disable file security in bucket settings
- ✅ Verify files are actually uploaded (check in Console)
- ✅ Use correct file URL format

### Build Fails

**Problem**: Build step shows errors

**Solution**:
- ✅ Test build locally: `cd apps/web && npm run build`
- ✅ Check for TypeScript errors: `npm run lint`
- ✅ Verify all dependencies are installed
- ✅ Check error details in Actions logs

### Secrets Not Working

**Problem**: Workflow says secrets are empty

**Solution**:
- ✅ Secret names must match exactly (case-sensitive)
- ✅ No spaces in secret names
- ✅ Re-add secrets if in doubt
- ✅ Secrets are at repository level, not organization

---

## Advanced Configuration

### Add Environment Variables

If you need environment variables in your build:

```yaml
- name: Build
  env:
    VITE_API_URL: ${{ secrets.API_URL }}
    VITE_CUSTOM_VAR: ${{ secrets.CUSTOM_VAR }}
  run: |
    cd apps/web
    npm run build
```

Then add those secrets to GitHub Settings.

### Deploy on Different Branch

Edit the workflow file to deploy from a different branch:

```yaml
on:
  push:
    branches:
      - production  # Change from 'main' to 'production'
```

### Deploy on Pull Requests (Previews)

Add PR preview deployments:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

Create separate bucket for PR previews: `web-dashboard-preview`

### Manual Deployment Trigger

You can manually trigger deployment:

1. GitHub → Actions
2. Select "Deploy Web Dashboard to Appwrite"
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow"

---

## Comparison: Appwrite vs Other Hosting

| Feature | Appwrite | Vercel | Netlify |
|---------|----------|---------|---------|
| **Same Backend** | ✅ Yes | ❌ No | ❌ No |
| **Cost** | ✅ Free | ✅ Free | ✅ Free |
| **Setup Time** | 5 min | 5 min | 5 min |
| **Auto Deploy** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Custom Domain** | ✅ Yes | ✅ Yes | ✅ Yes |
| **SPA Routing** | ⚠️ Manual | ✅ Auto | ✅ Auto |
| **Build Times** | ~2 min | ~2 min | ~2 min |
| **CDN** | ✅ Yes | ✅ Yes | ✅ Yes |

**Appwrite Advantages**:
- Same infrastructure as your backend
- No external dependencies
- Full control over data
- Integrated with your existing project

**Appwrite Considerations**:
- Need to handle SPA routing manually
- File upload via CLI (not web interface in workflow)
- Requires API key management

---

## Alternative: Appwrite Functions

For better SPA support, consider using Appwrite Functions:

1. **Create Function** in Appwrite Console
2. **Set Runtime**: Node.js or Static
3. **Upload Code**: Serve files from dist/
4. **Configure**: Handle routing (all paths → index.html)
5. **Deploy**: Function gets dedicated URL

This provides:
- ✅ Better SPA routing support
- ✅ Dedicated function URL
- ✅ Server-side capabilities if needed
- ✅ Environment variables support

---

## Security Best Practices

1. **API Keys**:
   - ✅ Use minimal required scopes
   - ✅ Set expiration dates
   - ✅ Rotate keys periodically
   - ✅ Never commit keys to code

2. **Bucket Permissions**:
   - ✅ Read: Public (`any`)
   - ✅ Write: Restricted (API key only)
   - ✅ File security: Disabled for static files

3. **Secrets**:
   - ✅ Use GitHub Secrets (never in code)
   - ✅ Limit access to repository collaborators
   - ✅ Audit secret usage regularly

---

## Next Steps

1. ✅ Complete the 5-minute setup above
2. ✅ Push a change to test automatic deployment
3. ✅ Configure custom domain (optional)
4. ✅ Consider Appwrite Functions for better SPA support
5. ✅ Monitor deployments in Actions tab

Your web dashboard now automatically deploys to Appwrite whenever you push code changes! 🚀

---

## Getting Help

- **GitHub Actions issues**: Check Actions tab → workflow run → logs
- **Appwrite issues**: Check [Appwrite documentation](https://appwrite.io/docs)
- **API Key problems**: Regenerate in Appwrite Console
- **General help**: Open an issue on GitHub

---

## Summary

**Benefits of Appwrite + GitHub Actions**:
- ✅ Automatic deployment on every push
- ✅ Same infrastructure as your backend
- ✅ No external hosting needed
- ✅ Free with your Appwrite plan
- ✅ Full control and ownership
- ✅ Integrated monitoring

Just add 3 secrets to GitHub, create a storage bucket, and your web dashboard automatically stays in sync with your Appwrite backend! 🎉
