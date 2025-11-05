# Deploy Web Dashboard from GitHub (No CLI Required!)

This guide shows you how to deploy the RPI Web Dashboard directly from GitHub without installing any CLI tools on your local machine.

## Overview

You have **3 easy options** to deploy without CLI:

1. **Vercel** - Connect GitHub repository (Recommended)
2. **Netlify** - Connect GitHub repository  
3. **Appwrite Console** - Manual upload via web interface

---

## Option 1: Vercel with GitHub (Recommended) 🚀

**Zero configuration, automatic deployments on every push**

### Setup Steps

1. **Go to [Vercel](https://vercel.com)**
   - Sign in with your GitHub account
   - Click "Add New Project"

2. **Import your GitHub repository**
   - Select `college-communication-app`
   - Vercel auto-detects the configuration

3. **Configure build settings**:
   - **Framework Preset**: Vite
   - **Root Directory**: `apps/web`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   
4. **Deploy**
   - Click "Deploy"
   - Wait 2-3 minutes for first deployment
   - Get your production URL: `https://your-project.vercel.app`

### Automatic Deployments

- Every push to `main` branch → automatic deployment
- Pull requests → preview deployments
- No manual steps needed ever again!

### Custom Domain (Optional)

1. Go to Project Settings → Domains
2. Add your domain (e.g., `dashboard.yourschool.edu`)
3. Configure DNS as instructed
4. SSL certificate auto-provisioned

### GitHub Actions (Pre-configured)

The repository includes `.github/workflows/deploy-web-dashboard.yml` that:
- Builds the project automatically
- Deploys to Vercel on every push
- No setup needed if you use Vercel directly

To enable:
1. Generate Vercel token: Settings → Tokens
2. Add to GitHub Secrets:
   - `VERCEL_TOKEN`
   - `VERCEL_ORG_ID`
   - `VERCEL_PROJECT_ID`

---

## Option 2: Netlify with GitHub 🎯

**Great alternative with similar features**

### Setup Steps

1. **Go to [Netlify](https://netlify.com)**
   - Sign in with GitHub
   - Click "Add new site" → "Import an existing project"

2. **Connect GitHub repository**
   - Select `college-communication-app`
   - Netlify auto-detects Vite

3. **Configure build**:
   - **Base directory**: `apps/web`
   - **Build command**: `npm run build`
   - **Publish directory**: `apps/web/dist`

4. **Deploy**
   - Click "Deploy site"
   - Get URL: `https://your-site.netlify.app`

### Automatic Deployments

- Push to main → auto-deploy
- PR previews enabled
- Rollback to any previous version

### Custom Domain

1. Site settings → Domain management
2. Add custom domain
3. Configure DNS
4. Free SSL included

---

## Option 3: Manual Upload to Appwrite Console 📁

**Simplest for occasional updates, no GitHub integration**

### Prerequisites
- Appwrite Cloud account
- Project already set up

### Steps

1. **Build locally** (one-time setup):
   ```bash
   cd apps/web
   npm install
   npm run build
   ```
   This creates a `dist/` folder with your website files.

2. **Go to Appwrite Console**:
   - Visit https://cloud.appwrite.io
   - Open your project

3. **Create Storage Bucket** (first time only):
   - Navigate to **Storage**
   - Click "Create Bucket"
   - Name: `web-dashboard`
   - Permissions: Set to public read
   - Enable "File Security": No (for static hosting)

4. **Upload files**:
   - Click on your bucket
   - Upload all files from `dist/` folder
   - Or zip `dist/` folder and upload
   - Wait for upload to complete

5. **Configure as website**:
   - Bucket settings → Enable static website hosting
   - Set index document: `index.html`
   - Set error document: `index.html` (for SPA routing)

6. **Access your site**:
   - URL: `https://[project-id].appwrite.global/storage/[bucket-id]/files/[file-id]/view`
   - Or configure custom domain in Appwrite

### Updating the Website

Repeat steps 1 and 4 whenever you want to update:
1. Build locally: `npm run build`
2. Delete old files in bucket
3. Upload new files from `dist/`

---

## Option 4: GitHub Pages (Free Hosting) 📄

**For public repositories only**

### Setup

1. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Source: GitHub Actions

2. **Use provided workflow**:
   The repository includes deployment workflow that runs on every push.

3. **Access**:
   - URL: `https://mufthakherul.github.io/college-communication-app/`

### Note
Requires updating `vite.config.ts` base path for GitHub Pages:
```typescript
export default defineConfig({
  base: '/college-communication-app/',
  // ... rest of config
})
```

---

## Comparison Table

| Feature | Vercel | Netlify | Appwrite Console | GitHub Pages |
|---------|--------|---------|------------------|--------------|
| **Setup Time** | 5 min | 5 min | 10 min | 15 min |
| **Auto Deploy** | ✅ Yes | ✅ Yes | ❌ Manual | ✅ Yes |
| **Custom Domain** | ✅ Free | ✅ Free | ✅ Free | ✅ Free |
| **HTTPS** | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto |
| **Preview Deploys** | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Rollback** | ✅ Easy | ✅ Easy | ❌ Manual | ⚠️ Via Git |
| **Build Time** | ~2 min | ~2 min | N/A | ~3 min |
| **CLI Required** | ❌ No | ❌ No | ❌ No | ❌ No |
| **Cost** | Free | Free | Free | Free |

---

## Recommended Setup

### For Continuous Development
→ **Use Vercel or Netlify** with GitHub connection
- Automatic deployments
- Preview environments
- Easy rollbacks
- Professional URLs

### For Quick Testing
→ **Use Appwrite Console** manual upload
- No GitHub connection needed
- Upload when ready
- Same infrastructure as backend

### For Public Projects
→ **Use GitHub Pages**
- Free hosting
- Automatic from repository
- Great for open source

---

## Troubleshooting

### Vercel/Netlify builds failing
- Check build logs in platform dashboard
- Verify `package.json` scripts are correct
- Ensure Node.js version is 18+

### Appwrite upload issues
- Check file size limits (10MB per file by default)
- Verify bucket permissions are public
- Ensure all files are uploaded from `dist/`

### Custom domain not working
- DNS propagation takes 24-48 hours
- Verify DNS records are correct
- Check SSL certificate status

---

## Need Help?

- **Vercel Issues**: https://vercel.com/docs
- **Netlify Issues**: https://docs.netlify.com
- **Appwrite Issues**: https://appwrite.io/docs
- **General Issues**: Open an issue on GitHub

---

## Next Steps

After deployment:

1. **Add custom domain** (optional)
2. **Configure Appwrite CORS** - Add your domain
3. **Test login** - Ensure Appwrite connection works
4. **Share URL** with teachers and admins
5. **Monitor** - Check analytics and logs

Your web dashboard is now live and accessible from anywhere! 🎉
