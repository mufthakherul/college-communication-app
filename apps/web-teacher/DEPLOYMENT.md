# Web Teacher Dashboard - Deployment Guide

This guide provides step-by-step instructions for deploying the RPI Teacher Dashboard to various hosting platforms.

## Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] Built the application successfully (`npm run build`)
- [ ] Tested locally with `npm run preview`
- [ ] Verified Appwrite configuration
- [ ] Confirmed no security vulnerabilities (`npm audit`)
- [ ] Reviewed and tested all features

## Quick Deployment Options

### 1. Vercel (Recommended) ⚡

**Best for**: Quick deployment with zero configuration

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Login to Vercel:
   ```bash
   vercel login
   ```

3. Deploy:
   ```bash
   cd apps/web-teacher
   vercel
   ```

4. Follow prompts:
   - Set project name
   - Confirm settings
   - Deploy!

**Vercel automatically:**
- Detects Vite configuration
- Runs build process
- Deploys to global CDN
- Provides HTTPS certificate
- Enables automatic deployments from Git

**Production URL**: `https://your-project.vercel.app`

### 2. Netlify 🎯

**Best for**: Easy deployment with great documentation

1. Install Netlify CLI:
   ```bash
   npm i -g netlify-cli
   ```

2. Login to Netlify:
   ```bash
   netlify login
   ```

3. Build the project:
   ```bash
   cd apps/web-teacher
   npm run build
   ```

4. Deploy:
   ```bash
   netlify deploy --prod --dir=dist
   ```

**Configuration** (`netlify.toml` - optional):
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 3. GitHub Pages 📄

**Best for**: Free hosting for public repositories

1. Install gh-pages:
   ```bash
   cd apps/web-teacher
   npm install --save-dev gh-pages
   ```

2. Add to `package.json`:
   ```json
   {
     "homepage": "https://yourusername.github.io/repo-name",
     "scripts": {
       "predeploy": "npm run build",
       "deploy": "gh-pages -d dist"
     }
   }
   ```

3. Deploy:
   ```bash
   npm run deploy
   ```

4. Enable GitHub Pages:
   - Go to repository settings
   - Select "Pages" section
   - Choose "gh-pages" branch
   - Save

**Note**: May require updating `vite.config.ts` base path:
```typescript
export default defineConfig({
  base: '/repo-name/',
  // ... rest of config
})
```

### 4. Firebase Hosting 🔥

**Best for**: Google Cloud integration

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase:
   ```bash
   cd apps/web-teacher
   firebase init hosting
   ```

4. Configure:
   - Choose existing project or create new
   - Set public directory: `dist`
   - Configure as single-page app: Yes
   - Don't overwrite index.html

5. Build and deploy:
   ```bash
   npm run build
   firebase deploy
   ```

**Configuration** (`firebase.json`):
```json
{
  "hosting": {
    "public": "dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 5. Docker Container 🐳

**Best for**: Self-hosted deployments, Kubernetes

1. Create `Dockerfile`:
   ```dockerfile
   # Build stage
   FROM node:20-alpine AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci
   COPY . .
   RUN npm run build

   # Production stage
   FROM nginx:alpine
   COPY --from=builder /app/dist /usr/share/nginx/html
   COPY nginx.conf /etc/nginx/conf.d/default.conf
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. Create `nginx.conf`:
   ```nginx
   server {
     listen 80;
     server_name localhost;
     root /usr/share/nginx/html;
     index index.html;

     location / {
       try_files $uri $uri/ /index.html;
     }

     # Gzip compression
     gzip on;
     gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
   }
   ```

3. Build and run:
   ```bash
   docker build -t rpi-teacher-dashboard .
   docker run -p 8080:80 rpi-teacher-dashboard
   ```

4. Push to registry (optional):
   ```bash
   docker tag rpi-teacher-dashboard username/rpi-teacher-dashboard
   docker push username/rpi-teacher-dashboard
   ```

### 6. Traditional Web Server (Apache/Nginx) 🌐

**Best for**: Existing web server infrastructure

#### Apache

1. Build the project:
   ```bash
   npm run build
   ```

2. Upload `dist/` contents to web server

3. Create `.htaccess` in root:
   ```apache
   <IfModule mod_rewrite.c>
     RewriteEngine On
     RewriteBase /
     RewriteRule ^index\.html$ - [L]
     RewriteCond %{REQUEST_FILENAME} !-f
     RewriteCond %{REQUEST_FILENAME} !-d
     RewriteRule . /index.html [L]
   </IfModule>

   # Enable GZIP compression
   <IfModule mod_deflate.c>
     AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
   </IfModule>
   ```

#### Nginx

1. Build the project:
   ```bash
   npm run build
   ```

2. Upload `dist/` contents to `/var/www/rpi-dashboard`

3. Configure Nginx (`/etc/nginx/sites-available/rpi-dashboard`):
   ```nginx
   server {
     listen 80;
     server_name dashboard.example.com;
     root /var/www/rpi-dashboard;
     index index.html;

     location / {
       try_files $uri $uri/ /index.html;
     }

     # Gzip compression
     gzip on;
     gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
     gzip_min_length 1000;

     # Cache static assets
     location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
     }
   }
   ```

4. Enable site and restart:
   ```bash
   sudo ln -s /etc/nginx/sites-available/rpi-dashboard /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Post-Deployment Configuration

### 1. Configure Appwrite CORS

Add your deployed domain to Appwrite:

1. Go to Appwrite Console
2. Select your project
3. Go to Settings → Platforms
4. Add Web platform:
   - Name: RPI Teacher Dashboard
   - Hostname: `your-domain.com`

### 2. Setup Custom Domain (Optional)

Most platforms support custom domains:

**Vercel:**
1. Go to project settings
2. Add domain
3. Configure DNS records

**Netlify:**
1. Go to Domain settings
2. Add custom domain
3. Configure DNS or use Netlify DNS

### 3. Enable HTTPS

All recommended platforms provide free HTTPS:
- Vercel: Automatic
- Netlify: Automatic
- GitHub Pages: Automatic for `.github.io` domains
- Firebase: Automatic

For self-hosted, use Let's Encrypt:
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d dashboard.example.com
```

### 4. Setup Environment Variables (if needed)

If you need different configs per environment:

**Vercel/Netlify:**
- Add in project settings → Environment variables

**Docker:**
```bash
docker run -p 8080:80 \
  -e VITE_API_URL=https://api.example.com \
  rpi-teacher-dashboard
```

## Monitoring and Maintenance

### 1. Setup Analytics (Optional)

Add to `index.html` (or use platform analytics):

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_ID');
</script>
```

### 2. Monitor Uptime

Use services like:
- UptimeRobot (free)
- Pingdom
- StatusCake

### 3. Regular Updates

Keep dependencies updated:
```bash
cd apps/web-teacher
npm update
npm audit fix
```

### 4. Backup Strategy

- Code: Stored in Git
- Configuration: Document in repository
- Database: Managed by Appwrite

## Troubleshooting

### Blank Page After Deployment

**Problem**: App shows blank page or 404s

**Solution**:
1. Check browser console for errors
2. Verify base path in `vite.config.ts`
3. Check SPA routing configuration
4. Verify all assets loaded correctly

### CORS Errors

**Problem**: API requests fail with CORS errors

**Solution**:
1. Add domain to Appwrite platforms
2. Check Appwrite endpoint URL
3. Verify HTTPS is enabled
4. Clear browser cache

### Build Fails

**Problem**: Build process fails

**Solution**:
1. Check Node.js version (must be 18+)
2. Delete `node_modules` and reinstall
3. Check for TypeScript errors: `npm run lint`
4. Review build logs for specific errors

### Slow Load Times

**Problem**: Application loads slowly

**Solution**:
1. Enable GZIP compression on server
2. Implement caching headers
3. Use CDN (most platforms include this)
4. Optimize images and assets
5. Consider code splitting

## Performance Optimization

### 1. Enable Compression

Most platforms enable by default. For self-hosted:

**Nginx:**
Already included in config above

**Apache:**
Already included in .htaccess above

### 2. Implement Caching

Add to production build:

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          mui: ['@mui/material', '@mui/icons-material'],
          appwrite: ['appwrite'],
        }
      }
    }
  }
})
```

### 3. Monitor Performance

Use tools:
- Lighthouse (Chrome DevTools)
- WebPageTest
- GTmetrix

## Security Best Practices

1. **Always use HTTPS** in production
2. **Keep dependencies updated** regularly
3. **Use Content Security Policy** headers
4. **Enable security headers**:
   ```nginx
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-XSS-Protection "1; mode=block" always;
   ```
5. **Monitor Appwrite logs** for suspicious activity
6. **Implement rate limiting** if self-hosting

## Rollback Strategy

### Vercel/Netlify
- Built-in: Use platform dashboard to rollback to previous deployment

### Docker
```bash
# Keep previous version
docker tag rpi-teacher-dashboard:latest rpi-teacher-dashboard:backup
# Rollback if needed
docker tag rpi-teacher-dashboard:backup rpi-teacher-dashboard:latest
```

### Manual
- Keep previous `dist/` folder as backup
- Restore if deployment fails

## Support

For deployment issues:
1. Check platform documentation
2. Review error logs
3. Test locally first
4. Contact platform support if needed

## Next Steps

After successful deployment:
1. Test all functionality
2. Share URL with teachers/admins
3. Monitor usage and performance
4. Gather feedback for improvements
5. Plan for regular updates

---

**Need Help?** 
- Platform Support: Check your hosting platform's documentation
- Appwrite Issues: https://appwrite.io/docs
- Application Issues: Open an issue on GitHub
