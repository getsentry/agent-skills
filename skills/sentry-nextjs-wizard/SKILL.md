---
name: sentry-nextjs-wizard
description: Setup Sentry in a Next.js project using the Sentry Wizard CLI. Use this when asked to add Sentry to a Next.js app, install Sentry SDK, configure error monitoring, or set up Sentry for Next.js. Supports headless/automated setup via CLI flags.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# Setup Sentry in Next.js Using the Wizard

This skill helps install and configure Sentry in Next.js projects using the official Sentry Wizard CLI tool. The wizard handles SDK installation, configuration file generation, and environment setup automatically.

## When to Use This Skill

Invoke this skill when:

- User asks to "add Sentry to my Next.js app"
- User wants to "install Sentry" in a Next.js project
- User requests "error monitoring" or "crash reporting" for Next.js
- User mentions "Sentry wizard" or "@sentry/nextjs"
- User wants automated Sentry setup without manual configuration
- User needs headless/CI-friendly Sentry installation

## Prerequisites

Before running the wizard, verify:

1. **Next.js project exists** - Check for `next` in `package.json`
2. **Node.js 18.20.0+** - Required by the wizard
3. **Package manager available** - npm, yarn, pnpm, or bun

```bash
# Verify Next.js is installed
grep '"next"' package.json

# Verify Node version
node --version
```

---

## Installation Methods

### Method 1: Headless Mode (Recommended for Agents)

Use `--skip-auth` mode for fully automated setup without browser authentication. This creates config files with environment variable placeholders that can be populated later.

```bash
npx @sentry/wizard@latest -i nextjs \
  --skip-auth \
  --tracing \
  --replay \
  --logs \
  --ignore-git-changes \
  --disable-telemetry
```

#### Available Flags for Headless Mode

| Flag                   | Description                                          | Default |
| ---------------------- | ---------------------------------------------------- | ------- |
| `--skip-auth`          | Skip Sentry authentication, use env var placeholders | `false` |
| `--tracing`            | Enable performance/tracing monitoring                | `false` |
| `--replay`             | Enable Session Replay                                | `false` |
| `--logs`               | Enable Sentry Logs                                   | `false` |
| `--tunnel-route`       | Enable tunnel route for ad-blocker circumvention     | `false` |
| `--ignore-git-changes` | Skip dirty git repo confirmation                     | `false` |
| `--disable-telemetry`  | Don't send telemetry to Sentry                       | `false` |
| `--force-install`      | Force install SDK without prompting                  | `false` |

#### MCP Configuration Flags

Add IDE-specific MCP (Model Context Protocol) configuration:

| Flag              | Description                                     |
| ----------------- | ----------------------------------------------- |
| `--mcp-cursor`    | Add MCP config for Cursor (`.cursor/mcp.json`)  |
| `--mcp-vscode`    | Add MCP config for VS Code (`.vscode/mcp.json`) |
| `--mcp-claude`    | Add MCP config for Claude Code (`.mcp.json`)    |
| `--mcp-opencode`  | Add MCP config for OpenCode (`opencode.json`)   |
| `--mcp-jetbrains` | Show MCP config for JetBrains IDEs              |

#### Example: Full Headless Setup with OpenCode MCP

```bash
npx @sentry/wizard@latest -i nextjs \
  --skip-auth \
  --tracing \
  --replay \
  --logs \
  --mcp-opencode \
  --ignore-git-changes \
  --disable-telemetry
```

### Method 2: Interactive Mode (With Authentication)

For setups that need immediate DSN configuration:

```bash
npx @sentry/wizard@latest -i nextjs
```

This will:

1. Open browser for Sentry authentication
2. Allow project selection/creation
3. Configure files with actual DSN values

#### Pre-select Org and Project

```bash
npx @sentry/wizard@latest -i nextjs --org my-org --project my-project
```

---

## Files Created by the Wizard

### In Headless Mode (`--skip-auth`)

| File                        | Purpose                                  |
| --------------------------- | ---------------------------------------- |
| `sentry.server.config.ts`   | Server-side Sentry initialization        |
| `sentry.edge.config.ts`     | Edge runtime Sentry initialization       |
| `instrumentation-client.ts` | Client-side Sentry initialization        |
| `instrumentation.ts`        | Next.js instrumentation hook             |
| `next.config.js`            | Modified to include `withSentryConfig`   |
| `global-error.tsx`          | App Router error boundary                |
| `_error.tsx`                | Pages Router error page (if applicable)  |
| `.env.example`              | Documents required environment variables |

### Environment Variables (Headless Mode)

After running with `--skip-auth`, populate these environment variables:

```bash
# .env.local (create from .env.example)

# Your Sentry DSN (from Project Settings > Client Keys)
SENTRY_DSN=https://xxxxx@o123.ingest.sentry.io/456

# Same DSN for client-side (NEXT_PUBLIC_ prefix exposes to browser)
NEXT_PUBLIC_SENTRY_DSN=https://xxxxx@o123.ingest.sentry.io/456

# Your organization slug
SENTRY_ORG=my-org

# Your project slug
SENTRY_PROJECT=my-project

# Auth token for source map uploads (from Organization Settings > Auth Tokens)
SENTRY_AUTH_TOKEN=sntrys_xxxxx
```

---

## Step-by-Step Agent Workflow

### Step 1: Detect Project Type

```bash
# Check for Next.js
grep '"next"' package.json
```

If Next.js is not found, inform user this skill is for Next.js projects only.

### Step 2: Check for Existing Sentry Installation

```bash
# Check if Sentry is already installed
grep '@sentry/nextjs' package.json
```

If already installed, ask user if they want to reconfigure.

### Step 3: Run the Wizard

For agent/automated setups, always use headless mode:

```bash
npx @sentry/wizard@latest -i nextjs \
  --skip-auth \
  --tracing \
  --replay \
  --logs \
  --ignore-git-changes \
  --disable-telemetry
```

### Step 4: Verify Installation

Check that files were created:

```bash
ls -la sentry.*.config.* instrumentation*.* .env.example 2>/dev/null
```

### Step 5: Populate Environment Variables

Read `.env.example` and create `.env.local` with actual values:

```bash
# Copy the example
cp .env.example .env.local
```

Then edit `.env.local` to add the actual Sentry credentials.

### Step 6: Verify Configuration

Check the generated config files use environment variables:

```bash
# Server config should use process.env.SENTRY_DSN
grep "process.env" sentry.server.config.*

# Client config should use process.env.NEXT_PUBLIC_SENTRY_DSN
grep "process.env" instrumentation-client.*

# next.config should use process.env.SENTRY_ORG and SENTRY_PROJECT
grep "process.env" next.config.*
```

---

## Generated Configuration Examples

### sentry.server.config.ts (Headless Mode)

```typescript
import * as Sentry from "@sentry/nextjs";

Sentry.init({
	dsn: process.env.SENTRY_DSN,

	// Tracing (if --tracing flag used)
	tracesSampleRate: 1,

	// Logs (if --logs flag used)
	enableLogs: true,

	sendDefaultPii: true,
});
```

### instrumentation-client.ts (Headless Mode)

```typescript
import * as Sentry from "@sentry/nextjs";

Sentry.init({
	dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

	// Replay (if --replay flag used)
	integrations: [Sentry.replayIntegration()],

	tracesSampleRate: 1,
	enableLogs: true,
	replaysSessionSampleRate: 0.1,
	replaysOnErrorSampleRate: 1.0,

	sendDefaultPii: true,
});

export const onRouterTransitionStart = Sentry.captureRouterTransitionStart;
```

### next.config.js (Headless Mode)

```javascript
const { withSentryConfig } = require("@sentry/nextjs");

const nextConfig = {};

module.exports = withSentryConfig(nextConfig, {
	org: process.env.SENTRY_ORG,
	project: process.env.SENTRY_PROJECT,

	silent: !process.env.CI,
	widenClientFileUpload: true,
	// tunnelRoute: "/monitoring",  // Uncomment if --tunnel-route used

	webpack: {
		automaticVercelMonitors: true,
		treeshake: {
			removeDebugLogging: true,
		},
	},
});
```

---

## Feature Flags Explained

### Tracing (`--tracing`)

Enables performance monitoring to track:

- Page load times
- API route performance
- Server component render times
- Database query durations

Adds `tracesSampleRate: 1` to config files.

### Session Replay (`--replay`)

Enables video-like reproduction of user sessions:

- Records DOM changes
- Captures user interactions
- Helps reproduce errors

Adds `replayIntegration()` and sampling rates to client config.

### Logs (`--logs`)

Enables structured logging to Sentry:

- Use `Sentry.logger.info()`, `.warn()`, `.error()`
- Searchable log attributes
- Correlated with errors and traces

Adds `enableLogs: true` to config files.

### Tunnel Route (`--tunnel-route`)

Routes Sentry requests through your Next.js server:

- Circumvents ad-blockers
- Increases server load
- Adds `tunnelRoute: "/monitoring"` to config

---

## Obtaining Sentry Credentials

After headless setup, guide users to get their credentials:

### DSN (Data Source Name)

1. Go to [sentry.io](https://sentry.io) and log in
2. Select your project (or create one)
3. Go to **Project Settings** > **Client Keys (DSN)**
4. Copy the DSN value

### Organization Slug

1. Go to **Organization Settings**
2. The slug is in the URL: `sentry.io/organizations/{org-slug}/`

### Project Slug

1. Go to **Project Settings**
2. The slug is shown at the top, or in the URL

### Auth Token

1. Go to **Organization Settings** > **Auth Tokens**
2. Click **Create New Token**
3. Select scopes: `org:read`, `project:releases`, `project:write`
4. Copy the generated token

---

## Common Issues and Solutions

### Issue: "Node.js version not supported"

The wizard requires Node.js 18.20.0 or higher.

```bash
node --version  # Check current version
nvm install 18  # Install Node 18 with nvm
```

### Issue: Wizard hangs on package installation

Use `--force-install` to skip prompts:

```bash
npx @sentry/wizard@latest -i nextjs --skip-auth --force-install
```

### Issue: Git dirty repo warning

Use `--ignore-git-changes` to skip the warning:

```bash
npx @sentry/wizard@latest -i nextjs --skip-auth --ignore-git-changes
```

### Issue: Config files not created in correct location

The wizard detects your project structure (App Router vs Pages Router, `src/` directory). If files are in unexpected locations:

1. Check if you have a `src/` directory
2. Check if you have `app/` or `pages/` in root vs `src/`
3. Files are placed according to Next.js conventions

### Issue: Source maps not uploading

Ensure `SENTRY_AUTH_TOKEN` is set in your environment and has correct permissions:

```bash
# In CI, set as environment variable
export SENTRY_AUTH_TOKEN=sntrys_xxxxx

# Or add to .env.local for local builds
SENTRY_AUTH_TOKEN=sntrys_xxxxx
```

---

## Verification Steps

After setup, verify Sentry is working:

### 1. Check for Errors in Build

```bash
npm run build
# or
yarn build
```

### 2. Test Error Capture

Add a test button to any page:

```tsx
<button
	onClick={() => {
		throw new Error("Sentry test error");
	}}
>
	Test Sentry
</button>
```

### 3. Check Sentry Dashboard

1. Go to your Sentry project
2. Navigate to **Issues**
3. Look for "Sentry test error"

### 4. Verify Source Maps (Production)

After deploying:

1. Trigger an error
2. Check the stack trace in Sentry
3. Verify it shows original source code, not minified

---

## Summary Checklist

```markdown
## Sentry Next.js Setup Complete

### Installation:

- [ ] Wizard executed successfully
- [ ] SDK installed (@sentry/nextjs)
- [ ] Configuration files created

### Configuration Files:

- [ ] sentry.server.config.ts/js
- [ ] sentry.edge.config.ts/js
- [ ] instrumentation-client.ts/js
- [ ] instrumentation.ts/js
- [ ] next.config.js updated
- [ ] global-error.tsx (App Router)

### Environment Variables:

- [ ] .env.example created (headless mode)
- [ ] .env.local created with actual values
- [ ] SENTRY_DSN set
- [ ] NEXT_PUBLIC_SENTRY_DSN set
- [ ] SENTRY_ORG set
- [ ] SENTRY_PROJECT set
- [ ] SENTRY_AUTH_TOKEN set

### Features Enabled:

- [ ] Error monitoring (always on)
- [ ] Tracing/Performance (if --tracing)
- [ ] Session Replay (if --replay)
- [ ] Logs (if --logs)

### Verification:

- [ ] Build completes without errors
- [ ] Test error appears in Sentry
- [ ] Source maps work in production
```

---

## Quick Reference

| Mode                    | Command                                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| Headless (all features) | `npx @sentry/wizard@latest -i nextjs --skip-auth --tracing --replay --logs --ignore-git-changes` |
| Headless (minimal)      | `npx @sentry/wizard@latest -i nextjs --skip-auth --ignore-git-changes`                           |
| Interactive             | `npx @sentry/wizard@latest -i nextjs`                                                            |
| With org/project        | `npx @sentry/wizard@latest -i nextjs --org my-org --project my-project`                          |

| Environment Variable     | Purpose                     | Required         |
| ------------------------ | --------------------------- | ---------------- |
| `SENTRY_DSN`             | Server-side error reporting | Yes              |
| `NEXT_PUBLIC_SENTRY_DSN` | Client-side error reporting | Yes              |
| `SENTRY_ORG`             | Source map uploads          | Yes (for builds) |
| `SENTRY_PROJECT`         | Source map uploads          | Yes (for builds) |
| `SENTRY_AUTH_TOKEN`      | Source map uploads          | Yes (for builds) |
