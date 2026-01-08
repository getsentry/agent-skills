# Sentry Agent Skills

Official agent skills for integrating Sentry into your projects. These skills provide AI coding assistants with the knowledge to set up and configure Sentry's error tracking, performance monitoring, logging, metrics, and AI agent monitoring.

## Available Skills

| Skill | Description |
|-------|-------------|
| `sentry-code-review` | Analyze and resolve Sentry comments on GitHub Pull Requests |
| `sentry-setup-ai-monitoring` | Setup Sentry AI Agent Monitoring for OpenAI, Anthropic, LangChain, etc. |
| `sentry-setup-logging` | Setup Sentry Logging for JavaScript, Python, and Ruby projects |
| `sentry-setup-metrics` | Setup Sentry Metrics (counters, gauges, distributions) |
| `sentry-setup-tracing` | Setup Sentry Tracing and Performance Monitoring |

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

Once installed, your AI assistant will automatically discover the skills. Simply ask it to:

- "Set up Sentry tracing in my project"
- "Add Sentry logging to my Next.js app"
- "Configure Sentry AI monitoring for my OpenAI integration"
- "Set up Sentry metrics"
- "Review the Sentry comments on PR #123"

The assistant will load the appropriate skill and guide you through the setup.

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
4. Provide comprehensive instructions in the markdown body

---

## License

Apache-2.0
