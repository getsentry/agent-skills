# Sentry Agent Skills

Official agent skills for integrating Sentry into your projects. These skills provide AI coding assistants with the knowledge to set up Sentry, debug production issues, and leverage Sentry's full observability platform.

## Available Skills

### SDK Skills (Full Platform Bundles)

| Skill | Description | Platforms | Docs |
|-------|-------------|-----------|------|
| `sentry-go-sdk` | Full Sentry setup wizard for Go — error monitoring, tracing, logging, metrics, crons | Go (net/http, Gin, Echo, Fiber) | [Go Guide](https://docs.sentry.io/platforms/go/) |
| `sentry-python-sdk` | Full Sentry setup wizard for Python — error monitoring, tracing, profiling, logging, metrics, crons, AI monitoring | Python (Django, Flask, FastAPI, Celery, Starlette, AIOHTTP) | [Python Guide](https://docs.sentry.io/platforms/python/) |
| `sentry-svelte-sdk` | Full Sentry setup wizard for Svelte/SvelteKit — error monitoring, tracing, session replay, logging | Svelte, SvelteKit | [SvelteKit Guide](https://docs.sentry.io/platforms/javascript/guides/sveltekit/) |
| `sentry-ruby-sdk` | Full Sentry setup wizard for Ruby — error monitoring, tracing, logging, Sidekiq metrics + dashboard, migration from AppSignal/Honeybadger | Ruby, Rails, Sinatra, Rack, Sidekiq | [Ruby Guide](https://docs.sentry.io/platforms/ruby/) |
| `sentry-cocoa-sdk` | Full Sentry setup wizard for Apple platforms — error monitoring, tracing, profiling, session replay, logging | iOS, macOS, tvOS, watchOS, visionOS (Swift, UIKit, SwiftUI) | [Apple Guide](https://docs.sentry.io/platforms/apple/) |
| `sentry-react-native-sdk` | Full Sentry setup wizard for React Native and Expo — error monitoring, tracing, profiling, session replay, logging, native crash symbolication | React Native, Expo managed/bare | [React Native Guide](https://docs.sentry.io/platforms/react-native/) |

### Setup Skills

| Skill | Description | Platforms | Docs |
|-------|-------------|-----------|------|
| `sentry-react-setup` | Setup Sentry in React apps | React | [React Guide](https://docs.sentry.io/platforms/javascript/guides/react/) |
| `sentry-react-native-setup` | Setup Sentry in React Native using the wizard CLI | React Native, Expo | [React Native Guide](https://docs.sentry.io/platforms/react-native/) |
| `sentry-ios-swift-setup` | Setup Sentry in iOS/Swift apps (superseded by `sentry-cocoa-sdk`) | iOS (Swift, UIKit, SwiftUI) | [Apple Guide](https://docs.sentry.io/platforms/apple/guides/ios/) |
| `sentry-setup-tracing` | Setup Sentry Tracing (Performance Monitoring) | JS, Python, Ruby | [Tracing](https://docs.sentry.io/platforms/javascript/tracing/) |
| `sentry-setup-logging` | Setup Sentry Logging | JS, Python, Ruby | [Logs](https://docs.sentry.io/platforms/javascript/logs/) |
| `sentry-setup-metrics` | Setup Sentry Metrics | JS, Python | [Metrics](https://docs.sentry.io/platforms/javascript/metrics/) |
| `sentry-setup-ai-monitoring` | Setup Sentry AI Agent Monitoring | JS, Python | [AI Monitoring](https://docs.sentry.io/product/ai-monitoring/) |

### Workflow Skills

| Skill | Description | Requirements | Docs |
|-------|-------------|--------------|------|
| `sentry-fix-issues` | Find and fix issues from Sentry using MCP | Sentry MCP | [Issues](https://docs.sentry.io/product/issues/) |
| `sentry-pr-code-review` | Review a project's PRs to check for issues detected in code review by Seer Bug Prediction | GitHub CLI | [Seer](https://docs.sentry.io/product/ai-in-sentry/seer/) |
| `sentry-create-alert` | Create Sentry alerts using the workflow engine API | `curl`, auth token | [Alerts](https://docs.sentry.io/product/alerts/) |

### Authoring Skills

| Skill | Description | Requirements |
|-------|-------------|--------------|
| `sentry-sdk-skill-creator` | Create a complete SDK skill bundle for any new platform — research, write, verify, and register | Web search, `claude` tool |

## Installation

### Quick Install (Recommended)

Install all skills using the [skills CLI](https://skills.sh):

```bash
npx skills add https://github.com/getsentry/sentry-agent-skills
```

Or install a specific skill:

```bash
npx skills add https://github.com/getsentry/sentry-agent-skills --skill sentry-fix-issues
```

Browse available skills at [skills.sh/getsentry/sentry-agent-skills](https://skills.sh/getsentry/sentry-agent-skills).

---

### Manual Installation

Choose your AI coding assistant below and run the appropriate command.

---

### Claude Code

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.claude/skills && \
  cp -r /tmp/sentry-skills/skills/* ~/.claude/skills/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .claude/skills && \
  cp -r /tmp/sentry-skills/skills/* .claude/skills/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.claude/skills/              # User-level
.claude/skills/                # Project-level

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

### OpenAI Codex

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.codex/skills && \
  cp -r /tmp/sentry-skills/skills/* ~/.codex/skills/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .codex/skills && \
  cp -r /tmp/sentry-skills/skills/* .codex/skills/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.codex/skills/               # User-level
.codex/skills/                 # Project-level

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

### GitHub Copilot

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.copilot/skills && \
  cp -r /tmp/sentry-skills/skills/* ~/.copilot/skills/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .github/skills && \
  cp -r /tmp/sentry-skills/skills/* .github/skills/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.copilot/skills/             # User-level
.github/skills/                # Project-level

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

### Cursor

> **Note:** Agent skills require Cursor Nightly. Enable via: `Cursor Settings > Rules > Import Settings > Agent Skills`

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.cursor/skills && \
  cp -r /tmp/sentry-skills/skills/* ~/.cursor/skills/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .cursor/skills && \
  cp -r /tmp/sentry-skills/skills/* .cursor/skills/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.cursor/skills/              # User-level
.cursor/skills/                # Project-level

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

### OpenCode

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.config/opencode/skill && \
  cp -r /tmp/sentry-skills/skills/* ~/.config/opencode/skill/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .opencode/skill && \
  cp -r /tmp/sentry-skills/skills/* .opencode/skill/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.config/opencode/skill/      # User-level
.opencode/skill/               # Project-level

# Also supports Claude-compatible paths:
~/.claude/skills/              # User-level (alternative)
.claude/skills/                # Project-level (alternative)

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

### AmpCode (Sourcegraph Amp)

**User-level (applies to all projects):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p ~/.config/agents/skills && \
  cp -r /tmp/sentry-skills/skills/* ~/.config/agents/skills/ && \
  rm -rf /tmp/sentry-skills
```

**Project-level (single repository):**
```bash
git clone https://github.com/getsentry/sentry-agent-skills.git /tmp/sentry-skills && \
  mkdir -p .agents/skills && \
  cp -r /tmp/sentry-skills/skills/* .agents/skills/ && \
  rm -rf /tmp/sentry-skills
```

<details>
<summary>Directory structure</summary>

```
~/.config/agents/skills/       # User-level
.agents/skills/                # Project-level

# Also supports Claude-compatible paths:
~/.claude/skills/              # User-level (alternative)
.claude/skills/                # Project-level (alternative)

# Each skill:
sentry-setup-tracing/
  SKILL.md
```
</details>

---

## Quick Reference

| Client | User-Level Path | Project-Level Path |
|--------|-----------------|-------------------|
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` |
| **Codex** | `~/.codex/skills/` | `.codex/skills/` |
| **Copilot** | `~/.copilot/skills/` | `.github/skills/` |
| **Cursor** | `~/.cursor/skills/` | `.cursor/skills/` |
| **OpenCode** | `~/.config/opencode/skill/` | `.opencode/skill/` |
| **AmpCode** | `~/.config/agents/skills/` | `.agents/skills/` |

---

## Usage

Once installed, your AI assistant will automatically discover the skills. Simply ask:

### SDK Skills (Full Platform Bundles)

| What to Say | Skill Used |
|-------------|------------|
| "Add Sentry to my Go app" | `sentry-go-sdk` |
| "Set up Sentry in my Gin/Echo/Fiber project" | `sentry-go-sdk` |
| "Add Sentry to my Python app" | `sentry-python-sdk` |
| "Set up Sentry in my Django/Flask/FastAPI project" | `sentry-python-sdk` |
| "Monitor my OpenAI/LangChain calls in Python" | `sentry-python-sdk` |
| "Add Sentry to my SvelteKit app" | `sentry-svelte-sdk` |
| "Set up Sentry in Svelte" | `sentry-svelte-sdk` |
| "Add Sentry to my Ruby/Rails app" | `sentry-ruby-sdk` |
| "Set up Sentry metrics for Puma/Sidekiq" | `sentry-ruby-sdk` |
| "Migrate from AppSignal to Sentry" | `sentry-ruby-sdk` |
| "Replace Honeybadger with Sentry" | `sentry-ruby-sdk` |
| "Add Sentry to my iOS app" | `sentry-cocoa-sdk` |
| "Set up Sentry in my Swift/SwiftUI project" | `sentry-cocoa-sdk` |
| "Add Sentry to my macOS app" | `sentry-cocoa-sdk` |
| "Add Sentry to my React Native app" | `sentry-react-native-sdk` |
| "Set up Sentry in Expo" | `sentry-react-native-sdk` |
| "Configure session replay for React Native" | `sentry-react-native-sdk` |

### Setup

| What to Say | Skill Used |
|-------------|------------|
| "Add Sentry to my React app" | `sentry-react-setup` |
| "Add Sentry to my iOS/Swift app" | `sentry-cocoa-sdk` |
| "Set up Sentry in React Native" | `sentry-react-native-setup` |
| "Add performance monitoring to my app" | `sentry-setup-tracing` |
| "Enable Sentry logging" | `sentry-setup-logging` |
| "Track custom metrics with Sentry" | `sentry-setup-metrics` |
| "Monitor my OpenAI/LangChain calls" | `sentry-setup-ai-monitoring` |

### Debugging & Workflow

| What to Say | Skill Used |
|-------------|------------|
| "Fix the recent Sentry errors" | `sentry-fix-issues` |
| "Debug the production TypeError" | `sentry-fix-issues` |
| "Work through my Sentry backlog" | `sentry-fix-issues` |
| "Review Sentry comments on PR #123" | `sentry-pr-code-review` |
| "Fix the issues Sentry found in my PR" | `sentry-pr-code-review` |
| "Create an alert that emails me when a high priority issue de-escalates" | `sentry-create-alert` |
| "Set up a Slack notification for new Sentry issues" | `sentry-create-alert` |
| `/sentry-create-alert` | `sentry-create-alert` |

The assistant will load the appropriate skill and guide you through the process.

---

## Skill Format

These skills follow the [Agent Skills specification](https://agentskills.io/specification). Each skill contains:

```
skill-name/
  SKILL.md        # Required: YAML frontmatter + markdown instructions
```

**SKILL.md structure:**
```markdown
---
name: skill-name
description: Description of what this skill does and when to use it
---

# Skill Title

Instructions for the AI assistant...
```

**SDK skill bundles** use a `references/` directory for feature-specific deep dives:

```
sentry-go-sdk/
  SKILL.md           # Main wizard
  references/
    error-monitoring.md
    tracing.md
    ...
```

---

## Contributing

Contributions are welcome! Please ensure any new skills:

1. Follow the [Agent Skills specification](https://agentskills.io/specification)
2. Have a valid `name` (lowercase letters, numbers, hyphens, 1-64 chars, no consecutive hyphens, must not start or end with hyphen)
3. Include a clear `description` (1-1024 chars)
4. Include an "Invoke This Skill When" section with trigger phrases
6. Verify technical details against [Sentry docs](https://docs.sentry.io/)

For full-platform SDK skills (covering all Sentry features for one language/framework), see [docs/sdk-skill-philosophy.md](docs/sdk-skill-philosophy.md) for the bundle architecture pattern.

### Style Guidelines

- Prefer tables over paragraphs for reference information
- Use phases/steps for multi-stage workflows
- Include version requirements where applicable
- Add troubleshooting tables for common issues
- SDK skill bundles should be comprehensive — use `references/` directories for deep-dive content loaded on demand

---

## License

Apache-2.0
