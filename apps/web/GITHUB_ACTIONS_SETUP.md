# GitHub Actions Auto-Deploy Setup Guide

Your repository already has a GitHub Actions workflow that automatically deploys your web dashboard whenever you push changes to the `main` branch or modify files in `apps/web/`.

## How It Works

✅ **Automatic**: Deploys on every push to `main` branch  
✅ **Smart**: Only triggers when `apps/web/` files change  
✅ **Fast**: Builds and deploys in ~2-3 minutes  
✅ **Live Updates**: Web app updates automatically when you edit the repo  

## Quick Setup (Choose One Platform)

### Option A: Vercel (Recommended)

**Step 1: Get Vercel Credentials**

1. Go to [vercel.com](https://vercel.com) and sign in with GitHub
2. Import your repository once (to create the project)
3. Go to Settings → Tokens → Create Token
   - Name: `GitHub Actions`
   - Scope: Full Access
   - Copy the token (starts with `vercel_...`)

4. Get Project IDs:
   - Go to your project Settings
   - Copy **Project ID** (e.g., `prj_abc123...`)
   - Copy **Team/Organization ID** from Settings → General

**Step 2: Add Secrets to GitHub**

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these 3 secrets:

   | Name | Value | Where to find |
   |------|-------|---------------|
   | `VERCEL_TOKEN` | Your Vercel token | Vercel → Settings → Tokens |
   | `VERCEL_ORG_ID` | Your org/team ID | Vercel → Project → Settings |
   | `VERCEL_PROJECT_ID` | Your project ID | Vercel → Project → Settings |

**Step 3: Done!**

That's it! Now:
- Edit any file in `apps/web/`
- Commit and push to `main` branch
- GitHub Actions automatically builds and deploys
- Check the **Actions** tab in GitHub to see progress
- Your changes are live in ~2 minutes!

---

### Option B: Netlify (Alternative)

**Step 1: Get Netlify Credentials**

1. Go to [netlify.com](https://netlify.com) and sign in with GitHub
2. Import your repository once
3. Go to User Settings → Applications → New access token
   - Name: `GitHub Actions`
   - Copy the token

4. Get Site ID:
   - Go to your site → Site settings
   - Copy **API ID** (e.g., `abc123-4567...`)

**Step 2: Add Secrets to GitHub**

Go to GitHub repository → Settings → Secrets and variables → Actions

Add these 2 secrets:

| Name | Value | Where to find |
|------|-------|---------------|
| `NETLIFY_AUTH_TOKEN` | Your token | Netlify → User Settings → Tokens |
| `NETLIFY_SITE_ID` | Your site API ID | Netlify → Site Settings |

**Step 3: Done!**

Now automatic deployments work:
- Push changes to `main` branch
- GitHub Actions builds and deploys
- Changes live in ~2 minutes

---

## Testing the Setup

### Method 1: Make a Small Change

1. Edit `apps/web/src/pages/LoginPage.tsx`
2. Change line 48 from:
   ```typescript
   RPI Dashboard
   ```
   to:
   ```typescript
   RPI Dashboard - Auto Deploy Test
   ```
3. Commit and push
4. Go to GitHub → Actions tab
5. Watch the workflow run (takes ~2 minutes)
6. Visit your deployed URL to see the change

### Method 2: Manual Trigger

1. Go to GitHub → Actions
2. Click "Deploy Web Dashboard" workflow
3. Click "Run workflow" → "Run workflow"
4. Watch it deploy without any code changes

---

## Workflow Details

The workflow (`.github/workflows/deploy-web-dashboard.yml`) does this:

1. **Triggers on**:
   - Push to `main` branch
   - Changes in `apps/web/**` files
   - Manual trigger via GitHub UI

2. **Build Process**:
   - Checks out code
   - Installs Node.js 20
   - Installs dependencies (`npm ci`)
   - Builds project (`npm run build`)
   - Deploys to chosen platform

3. **Deployment**:
   - Uses cached dependencies for speed
   - Deploys only if secrets are configured
   - Shows progress in Actions tab
   - Comments on commits with deploy URL

---

## Monitoring Deployments

### Check Deployment Status

**In GitHub:**
1. Go to repository → **Actions** tab
2. See all deployment runs
3. Click any run to see detailed logs
4. Green checkmark = successful deployment
5. Red X = failed (check logs)

**In Vercel/Netlify:**
- View deployment history
- See preview URLs
- Check build logs
- Monitor performance

### View Deployment Logs

1. GitHub → Actions → Click workflow run
2. Click "Deploy to Vercel" or "Deploy to Netlify" job
3. Expand each step to see details
4. Look for "Deploy" step to see URL

---

## Troubleshooting

### Workflow Not Running

**Problem**: Nothing happens when you push

**Solutions**:
- ✅ Check you pushed to `main` branch
- ✅ Verify changes are in `apps/web/` directory
- ✅ Check Actions tab for workflow runs
- ✅ Ensure workflow file exists in `.github/workflows/`

### Deployment Fails

**Problem**: Build succeeds but deployment fails

**Solutions**:
- ✅ Verify all 3 secrets are added correctly (no typos)
- ✅ Check Vercel/Netlify token hasn't expired
- ✅ Ensure project IDs match your actual project
- ✅ Check deployment logs in Actions tab

### Build Fails

**Problem**: Build step shows errors

**Solutions**:
- ✅ Test build locally: `cd apps/web && npm run build`
- ✅ Check TypeScript errors: `npm run lint`
- ✅ Verify `package.json` and dependencies
- ✅ Look at error details in Actions logs

### Secrets Not Working

**Problem**: Workflow says secrets are empty

**Solutions**:
- ✅ Secret names must match exactly (case-sensitive)
- ✅ No spaces in secret names
- ✅ Re-add secrets if in doubt
- ✅ Secrets are repository-level, not organization

---

## Advanced Configuration

### Change Deployment Branch

Edit `.github/workflows/deploy-web-dashboard.yml`:

```yaml
on:
  push:
    branches:
      - main        # Change this to your branch
      - production  # Or add multiple branches
```

### Deploy on Pull Requests

Add to `on:` section:

```yaml
on:
  push:
    branches:
      - main
  pull_request:  # Add this
    branches:
      - main
```

This creates preview deployments for PRs!

### Add Environment Variables

Add to workflow under "Build" step:

```yaml
- name: Build
  env:
    VITE_API_URL: ${{ secrets.API_URL }}
  run: |
    cd apps/web
    npm run build
```

Then add `API_URL` secret in GitHub.

---

## Multiple Environments

### Setup Staging and Production

1. Create two branches: `staging` and `main`
2. Configure separate secrets:
   - `VERCEL_TOKEN_STAGING` 
   - `VERCEL_TOKEN_PRODUCTION`
3. Create two workflows:
   - `deploy-staging.yml` (deploys from `staging` branch)
   - `deploy-production.yml` (deploys from `main` branch)

### Use Vercel/Netlify Projects

- Create separate projects for staging/production
- Use different `VERCEL_PROJECT_ID` for each
- Deploy automatically to correct environment

---

## Benefits of GitHub Actions

✅ **Automatic**: No manual deployment steps  
✅ **Consistent**: Same build process every time  
✅ **Fast**: Deploys in ~2 minutes  
✅ **Reliable**: GitHub's infrastructure  
✅ **Free**: Unlimited for public repos  
✅ **History**: See all past deployments  
✅ **Rollback**: Easy to revert changes  
✅ **Team-Friendly**: Everyone's changes deploy automatically  

---

## Next Steps

1. ✅ Choose Vercel or Netlify
2. ✅ Add secrets to GitHub (takes 2 minutes)
3. ✅ Push a change to test
4. ✅ Watch it deploy automatically
5. ✅ Share your live URL!

---

## Getting Help

- **GitHub Actions not working?** Check Actions tab → workflow run → logs
- **Vercel issues?** Check [Vercel documentation](https://vercel.com/docs)
- **Netlify issues?** Check [Netlify documentation](https://docs.netlify.com)
- **General help?** Open an issue on GitHub

---

## Summary

GitHub Actions provides the best deployment experience:
- **Zero manual work** after initial setup
- **Automatic updates** when you edit code
- **Live in 2 minutes** after every push
- **Free for public repositories**
- **Professional workflow** with history and logs

Just add 3 secrets to GitHub, and your web dashboard automatically stays in sync with your repository! 🚀
