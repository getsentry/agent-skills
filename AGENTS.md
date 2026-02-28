# Sentry Agent Skills

Official agent skills for integrating Sentry into projects. These skills are designed for AI coding assistants that support the [Agent Skills specification](https://agentskills.io).

## Repository Structure

```
skills/
  <skill-name>/
    SKILL.md          # Required: YAML frontmatter + markdown instructions
README.md             # Installation instructions for all supported clients
AGENTS.md             # This file - authoring guidelines
```

## Supported Clients

Skills are compatible with any client supporting the Agent Skills spec:
- Claude Code (`~/.claude/skills/` or `.claude/skills/`)
- OpenAI Codex (`~/.codex/skills/` or `.codex/skills/`)
- GitHub Copilot (`~/.copilot/skills/` or `.github/skills/`)
- Cursor (`~/.cursor/skills/` or `.cursor/skills/`)
- OpenCode (`~/.config/opencode/skill/` or `.opencode/skill/`)
- AmpCode (`~/.config/agents/skills/` or `.agents/skills/`)

## Creating a Skill

### 1. Create the Skill File

```bash
mkdir -p skills/<skill-name>
touch skills/<skill-name>/SKILL.md
```

### 2. Add YAML Frontmatter

```yaml
---
name: skill-name
description: Brief description including trigger keywords. Use when asked to [action]. Supports [platforms].
---
```

**Required fields:**
| Field | Requirements |
|-------|--------------|
| `name` | kebab-case, 1-64 chars, must match directory name, no consecutive hyphens, must not start or end with hyphen |
| `description` | 1-1024 chars, include trigger phrases and supported platforms |

**Optional fields:**
| Field | Purpose |
|-------|---------|
| `metadata` | Arbitrary key-value mapping (e.g., `author`, `version`) |
| `allowed-tools` | Space-delimited tool allowlist (experimental) |
| `license` | License name or path |
| `compatibility` | Environment requirements (max 500 chars) |

### 3. Write the Skill Body

Follow the structure and style guidelines below.

### 4. Update README.md

Add the skill to the appropriate table in the Available Skills section.

## Skill Structure

Every skill should follow this structure:

```markdown
---
name: skill-name
description: ...
---

# Skill Title

One-sentence summary of what this skill does.

## Invoke This Skill When

- Bullet list of trigger phrases
- "User asks to..."
- "User wants to..."

## Prerequisites (if any)

Requirements before the skill can be used.

## Phase 1: First Step
...

## Phase N: Final Step
...

## Quick Reference Tables
...

## Troubleshooting

| Issue | Solution |
|-------|----------|
```

## Style Guidelines

### Comprehensive Over Concise

Skills should be thorough and all-encompassing. Use `references/` directories to split deep-dive content into separate files loaded on demand — this keeps the main wizard lean while allowing references to go deep.

| Do | Don't |
|----|-------|
| Tables for reference data | Long prose where a table works better |
| Complete, working code examples | Incomplete snippets that need guesswork |
| Deep-dive references for each feature | Superficial coverage that omits details |
| Comprehensive troubleshooting | Leaving users to figure out edge cases |

### Phases for Workflows

For multi-step skills (especially workflow skills like debugging), use numbered phases:

```markdown
## Phase 1: Discovery
What to find/gather first.

## Phase 2: Analysis
How to analyze the gathered information.

## Phase 3: Implementation
How to make changes.

## Phase 4: Verification
How to verify the changes worked.
```

### Self-Challenging Verification

For workflow skills that fix issues, include verification checklists that force the agent to challenge its own work:

```markdown
## Phase N: Verification Audit

Before declaring complete, answer honestly:
- [ ] Does the fix address the root cause, not just a symptom?
- [ ] Have I considered all available context?
- [ ] Could this fix break existing functionality?
- [ ] Are there similar issues elsewhere that need the same fix?
```

### Include Trigger Phrases

The "Invoke This Skill When" section helps agents know when to load the skill:

```markdown
## Invoke This Skill When

- User asks to "setup Sentry logging" or "enable logs"
- User wants to integrate Pino, Winston, or Loguru with Sentry
- User mentions `Sentry.logger` or structured logging
```

### Version Requirements

Always include minimum SDK versions in a table:

```markdown
| Platform | Min SDK | Feature |
|----------|---------|---------|
| JavaScript | 9.41.0+ | Logging |
| Python | 2.35.0+ | Logging |
| Ruby | 5.24.0+ | Logging |
```

### Troubleshooting Tables

End skills with common issues and solutions:

```markdown
## Troubleshooting

| Issue | Solution |
|-------|----------|
| Logs not appearing | Verify SDK version, check `enableLogs` is set |
| Too many logs | Use `beforeSendLog` to filter |
```

## Skill Categories

### Setup Skills

Configure Sentry features in a project. Pattern:
1. Detect project type/existing config
2. Check SDK version
3. Add configuration
4. Verify setup

### SDK Skill Bundles

Full SDK setup wizards that scan the project, make opinionated feature recommendations, and guide through setup of error monitoring, tracing, profiling, logging, and more. Each bundle is a directory with a main `SKILL.md` wizard and `references/` deep-dive files loaded conditionally.

See **[skills/sentry-sdk-skill-creator/references/philosophy.md](skills/sentry-sdk-skill-creator/references/philosophy.md)** for the complete authoring guide: bundle architecture, wizard flow, reference file format, and naming conventions.

### Workflow Skills

Use Sentry to accomplish tasks (debugging, code review). Pattern:
1. Gather information (from Sentry, GitHub, etc.)
2. Analyze systematically
3. Take action
4. Verify and report results

## Technical Accuracy

**Always verify against official Sentry docs** before publishing. Examples of Sentry docs are below:
- https://docs.sentry.io/platforms/javascript/
- https://docs.sentry.io/platforms/python/
- https://docs.sentry.io/platforms/ruby/

Common things to verify:
- Minimum SDK versions for features
- Correct API names, methods, and signatures
- Auto-enabled vs explicit integrations
- Platform-specific requirements (e.g., Next.js needs `instrumentOpenAiClient()` wrapper)

## Testing Skills

Before merging, test the skill by:
1. Installing it in your client
2. Asking trigger phrases to verify it loads
3. Following the skill instructions on a test project
4. Verifying the output matches Sentry docs

## References

- [Agent Skills Specification](https://agentskills.io/specification)
- [Sentry Documentation](https://docs.sentry.io/)
- [Sentry SDK Changelogs](https://github.com/getsentry/sentry-javascript/releases)
