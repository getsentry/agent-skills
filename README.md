# Sentry Agent Skills

Official agent skills for integrating Sentry into your projects. These skills provide AI coding assistants with the knowledge to set up Sentry, debug production issues, and leverage Sentry's full observability platform.

## Available Skills

### Setup Skills

| Skill | Description | Platforms | Docs |
|-------|-------------|-----------|------|
| `sentry-nextjs-setup` | Setup Sentry in Next.js using the wizard CLI | Next.js | [Next.js Guide](https://docs.sentry.io/platforms/javascript/guides/nextjs/) |
| `sentry-react-setup` | Setup Sentry in React apps | React | [React Guide](https://docs.sentry.io/platforms/javascript/guides/react/) |
| `sentry-react-native-setup` | Setup Sentry in React Native using the wizard CLI | React Native, Expo | [React Native Guide](https://docs.sentry.io/platforms/react-native/) |
| `sentry-python-setup` | Setup Sentry in Python apps (Django, Flask, FastAPI) | Python | [Python Guide](https://docs.sentry.io/platforms/python/) |
| `sentry-ruby-setup` | Setup Sentry in Ruby apps (Rails) | Ruby | [Ruby Guide](https://docs.sentry.io/platforms/ruby/) |
| `sentry-setup-tracing` | Setup tracing, transactions, spans, and performance monitoring | JS, Python, Ruby | [Tracing](https://docs.sentry.io/platforms/javascript/tracing/) |
| `sentry-setup-logging` | Setup structured logging and integrate Pino/Winston/Loguru | JS, Python, Ruby | [Logs](https://docs.sentry.io/platforms/javascript/logs/) |
| `sentry-setup-metrics` | Setup custom metrics (counters, gauges, distributions) | JS, Python | [Metrics](https://docs.sentry.io/platforms/javascript/metrics/) |
| `sentry-setup-ai-monitoring` | Setup AI/LLM monitoring for OpenAI, Anthropic, LangChain, etc. | JS, Python | [AI Agents](https://docs.sentry.io/platforms/javascript/guides/nextjs/tracing/instrumentation/ai-agents-module/) |

### Workflow Skills

| Skill | Description | Requirements | Docs |
|-------|-------------|--------------|------|
| `sentry-fix-issues` | Find and fix production issues using Sentry MCP | Sentry MCP | [Issues](https://docs.sentry.io/product/issues/) |
| `sentry-pr-code-review` | Analyze and resolve Sentry Seer comments on GitHub PRs | GitHub CLI | [Seer](https://docs.sentry.io/product/ai-in-sentry/seer/) |

## Installation

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

### Setup

| What to Say | Skill Used |
|-------------|------------|
| "Set up Sentry in my Next.js app" | `sentry-nextjs-setup` |
| "Add Sentry to my React app" | `sentry-react-setup` |
| "Set up Sentry in React Native" | `sentry-react-native-setup` |
| "Add Sentry to my Python/Django/Flask app" | `sentry-python-setup` |
| "Set up Sentry in my Ruby/Rails app" | `sentry-ruby-setup` |
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

---

## Contributing

Contributions are welcome! Please ensure any new skills:

1. Follow the [Agent Skills specification](https://agentskills.io/specification)
2. Have a valid `name` (lowercase, hyphens, 1-64 chars)
3. Include a clear `description` (1-1024 chars)
4. **Keep skills concise** - use tables over prose, avoid obvious information
5. Include an "Invoke This Skill When" section with trigger phrases
6. Verify technical details against [Sentry docs](https://docs.sentry.io/)

### Style Guidelines

- Prefer tables over paragraphs for reference information
- Use phases/steps for multi-stage workflows
- Include version requirements where applicable
- Add troubleshooting tables for common issues
- Target ~100-200 lines per skill to minimize token usage

---

## License

Apache-2.0
