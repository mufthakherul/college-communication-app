#!/usr/bin/env bash
set -euo pipefail

# Optional: source env file if present
ENV_FILE="tools/mcp/appwrite.mcp.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$ENV_FILE" | xargs -d '\n')
fi

: "${APPWRITE_ENDPOINT?APPWRITE_ENDPOINT is required}"
: "${APPWRITE_PROJECT_ID?APPWRITE_PROJECT_ID is required}"
: "${APPWRITE_API_KEY?APPWRITE_API_KEY is required}"

exec uvx mcp-server-appwrite --sites
