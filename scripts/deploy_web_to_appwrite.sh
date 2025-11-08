#!/usr/bin/env bash
set -euo pipefail

# Deploy built web assets in apps/web/dist to Appwrite using the sites API.
# Requires environment variables:
#  APPWRITE_ENDPOINT - e.g. https://sgp.cloud.appwrite.io/v1
#  APPWRITE_PROJECT  - Appwrite project ID
#  APPWRITE_API_KEY  - API key with write permissions for Sites
#  SITE_ID           - Site ID from appwrite.json (e.g. web-dashboard)
#
# If not built yet, run build first.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/apps/web/dist"

if [ ! -d "$DIST_DIR" ]; then
  echo "Dist directory not found: $DIST_DIR. Run npm run build in apps/web first." >&2
  exit 1
fi

missing=()
for v in APPWRITE_ENDPOINT APPWRITE_PROJECT APPWRITE_API_KEY SITE_ID; do
  if [ -z "${!v:-}" ]; then
    missing+=("$v")
  fi
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing required env vars: ${missing[*]}" >&2
  exit 1
fi

echo "Packing dist directory..."
TMP_ZIP="$(mktemp /tmp/webdist.XXXXXX).zip"
cd "$DIST_DIR"
zip -qr "$TMP_ZIP" .
cd - >/dev/null
echo "Created archive: $TMP_ZIP"

echo "Uploading deployment to Appwrite site $SITE_ID..."
UPLOAD_RESPONSE=$(curl -s -X POST "$APPWRITE_ENDPOINT/sites/$SITE_ID/deployments" \
  -H "X-Appwrite-Project: $APPWRITE_PROJECT" \
  -H "X-Appwrite-Key: $APPWRITE_API_KEY" \
  -F "entry=@$TMP_ZIP") || { echo "Upload failed"; exit 1; }

echo "$UPLOAD_RESPONSE" | jq '.' || echo "$UPLOAD_RESPONSE"

DEPLOY_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '."$id"')
if [ -z "$DEPLOY_ID" ] || [ "$DEPLOY_ID" = "null" ]; then
  echo "Failed to extract deployment id from response." >&2
  exit 1
fi

echo "Deployment created with id: $DEPLOY_ID"
echo "Done."
