# Appwrite MCP integration (API + Docs)

This project includes ready-to-use configuration for GitHub Copilot to connect to your Appwrite project via MCP (Model Context Protocol):

- **Appwrite MCP API server** — lets Copilot call Appwrite APIs directly against your rpi-communication project
- **Appwrite MCP Docs server** — gives Copilot authoritative Appwrite documentation context (HTTP endpoint)

Reference: https://appwrite.io/docs/tooling/mcp/vscode

---

## ✅ Already configured for you!

### 1) Environment variables (done!)

The file `tools/mcp/appwrite.mcp.env` is already populated with your credentials:

- `APPWRITE_ENDPOINT` → https://sgp.cloud.appwrite.io/v1 (Singapore region)
- `APPWRITE_PROJECT_ID` → 6904cfb1001e5253725b (rpi-communication)
- `APPWRITE_API_KEY` → (your standard API key)

> **Security note:** This file is already in `.gitignore`. Never commit real API keys to public repos.

### 2) GitHub Copilot MCP config (done!)

Your GitHub Copilot MCP config is ready at `.vscode/github-copilot-mcp.json`. GitHub Copilot will auto-discover the Appwrite MCP servers from this file.

**What's included:**

- `appwrite-docs` — HTTP endpoint (https://mcp-for-docs.appwrite.io) for Appwrite documentation
- `appwrite-api` — local `uvx` command to interact with your Appwrite project APIs

---

## 📋 Prerequisites

### For API server (required)

**Install `uv` (Python package installer):**

```bash
# Linux/macOS/WSL
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or via pip
pip install uv

# Verify installation
uv --version
```

> **Note:** The API server uses `uvx mcp-server-appwrite` which requires `uv` to be installed.

### For Docs server (no installation needed)

The Docs server is a hosted HTTP endpoint at `https://mcp-for-docs.appwrite.io`. No local installation required!

---

## 🚀 Activation

**Reload VS Code:**

```bash
# Ctrl+Shift+P → "Developer: Reload Window"
```

After reload, GitHub Copilot will auto-detect the MCP servers from `.vscode/github-copilot-mcp.json`.

**Try these questions:**

- "List all collections in my Appwrite database"
- "Show me the schema for the users collection"
- "What's the recommended way to handle Appwrite realtime subscriptions?"
- "Create a new document in the notices collection"

---

## 🧪 Optional: Manual server testing

### API server

```bash
bash scripts/mcp/start-appwrite-mcp-api.sh
```

This will launch the API MCP server using `uvx mcp-server-appwrite --sites`. The script automatically sources `tools/mcp/appwrite.mcp.env` for credentials.

### Docs server

The Docs server doesn't need to run locally—it's a hosted HTTP endpoint. Running `scripts/mcp/start-appwrite-mcp-docs.sh` will just display this info.

---

## 🔧 Alternative VS Code agents

If you're using Claude for VS Code or Continue.dev instead of GitHub Copilot, sample configs are available:

- **Claude for VS Code:** `tools/mcp/claude.config.json`
- **Continue.dev:** `tools/mcp/continue.config.json`

**For Claude:** Open VS Code Settings (JSON) and merge the entries into Claude's MCP settings.  
**For Continue:** Merge into `~/.continue/config.json` under `mcpServers`.

Both configs use:

- `uvx mcp-server-appwrite --sites` for API
- `https://mcp-for-docs.appwrite.io` (HTTP) for Docs

---

## 🔒 Security notes

- Treat your API key as a secret. Rotate keys regularly.
- Prefer least-privilege keys and scope them minimally for the operations you need.
- If you self-host Appwrite behind a VPN or tunnel, ensure your IDE can reach the endpoint.
- The `.gitignore` already includes `tools/mcp/appwrite.mcp.env` to prevent key leaks.

---

## 🐛 Troubleshooting

### "uv must be installed on your system"

Install `uv` using the instructions in the Prerequisites section above.

### IDE doesn't see the MCP servers

- Ensure GitHub Copilot is installed and active
- Reload VS Code after creating `.vscode/github-copilot-mcp.json`
- Check that `uv` is available on your PATH: `uv --version`
- Verify env variables exist in `tools/mcp/appwrite.mcp.env`

### API calls fail with 401/403

- Re-check project ID, endpoint, and API key in `tools/mcp/appwrite.mcp.env`
- Verify the API key has the required scopes for the operations you're attempting
- Test the endpoint is reachable: `curl https://sgp.cloud.appwrite.io/v1/health`

### Copilot doesn't respond with Appwrite context

- Give it time to initialize the MCP connection (first run can take a few seconds)
- Try asking an explicit question like "What Appwrite collections exist in my project?"
- Check the VS Code Output panel (select "GitHub Copilot" or "MCP" channels if available)
- Ensure `uv` is properly installed and accessible

### Docs server not working

The Docs server is a hosted HTTP endpoint, so there's nothing to install. If it's not responding:

- Check your internet connection
- Verify the URL is reachable: `curl https://mcp-for-docs.appwrite.io`
- GitHub Copilot should automatically connect to it—no local process needed

---

## 📂 File structure

```
.vscode/
  github-copilot-mcp.json  ← Copilot discovers this automatically

tools/mcp/
  README.md                 ← This file
  appwrite.mcp.env          ← Your credentials (gitignored)
  appwrite.mcp.env.sample   ← Template for others
  claude.config.json        ← Alternative: Claude for VS Code
  continue.config.json      ← Alternative: Continue.dev

scripts/mcp/
  start-appwrite-mcp-api.sh   ← Manual API server launch (uses uvx)
  start-appwrite-mcp-docs.sh  ← Info script (Docs is HTTP endpoint)
```
