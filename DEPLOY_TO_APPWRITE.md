# Deploying to Appwrite

## Prerequisites

1. Appwrite CLI installed:

   ```bash
   npm install -g appwrite-cli
   ```

2. Appwrite account configured:
   ```bash
   appwrite login
   ```

## Quick Deploy

Run the deployment script:

```bash
./deploy-appwrite.sh
```

This will:

1. ✓ Install dependencies
2. ✓ Build the React app
3. ✓ Deploy to Appwrite hosting

## Manual Deploy

If you prefer to deploy manually:

```bash
# 1. Navigate to web app
cd apps/web

# 2. Install dependencies
npm install

# 3. Build the app
npm run build

# 4. Go back to root
cd ../..

# 5. Deploy to Appwrite
appwrite push sites
```

## Verify Deployment

After deployment:

1. Check Appwrite console: https://cloud.appwrite.io
2. Navigate to your project: `rpi-communication`
3. Go to "Sites" section
4. Click on "RPI Communication Dashboard"
5. Open the live URL

## Configuration

The deployment is configured in `appwrite.json`:

```json
{
  "projectId": "6904cfb1001e5253725b",
  "projectName": "rpi-communication",
  "sites": [
    {
      "$id": "web-dashboard",
      "name": "RPI Communication Dashboard",
      "buildCommand": "cd apps/web && npm install && npm run build",
      "outputDirectory": "apps/web/dist"
    }
  ]
}
```

## Custom Domain

To add a custom domain:

1. Go to Appwrite Console
2. Navigate to Sites > RPI Communication Dashboard
3. Click "Add Domain"
4. Follow the DNS configuration instructions

## Troubleshooting

### Build fails

```bash
cd apps/web
npm run build
# Check for errors
```

### Appwrite CLI not logged in

```bash
appwrite login
```

### Permission denied on deploy script

```bash
chmod +x deploy-appwrite.sh
```

## Support

- Email: info@rangpur.polytech.gov.bd
- Developer: www.mufthakherul.me
