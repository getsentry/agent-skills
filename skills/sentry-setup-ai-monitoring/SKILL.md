---
name: sentry-setup-ai-monitoring
description: Setup Sentry AI Agent Monitoring in any project. Use when asked to monitor LLM calls, track AI agents, or instrument OpenAI/Anthropic/Vercel AI/LangChain/Google GenAI. Detects installed AI SDKs and configures appropriate integrations.
---

# Setup Sentry AI Agent Monitoring

Configure Sentry to track LLM calls, agent executions, tool usage, and token consumption.

## Invoke This Skill When

- User asks to "monitor AI/LLM calls" or "track OpenAI/Anthropic usage"
- User wants "AI observability" or "agent monitoring"
- User asks about token usage, model latency, or AI costs

**Important:** The SDK versions, API names, and code samples below are examples. Always verify against [docs.sentry.io](https://docs.sentry.io) before implementing, as APIs and minimum versions may have changed.

## Prerequisites

AI monitoring requires **tracing enabled** (`tracesSampleRate > 0`).

## Detection First

**Always detect installed AI SDKs before configuring:**

```bash
# JavaScript
grep -E '"(openai|@anthropic-ai/sdk|ai|@langchain|@google/genai)"' package.json

# Python
grep -E '(openai|anthropic|langchain|huggingface)' requirements.txt pyproject.toml 2>/dev/null
```

## Supported SDKs

### JavaScript

| Package | Integration | Min Sentry SDK | Auto? |
|---------|-------------|----------------|-------|
| `openai` | `openAIIntegration()` | 10.28.0 | Yes |
| `@anthropic-ai/sdk` | `anthropicAIIntegration()` | 10.28.0 | Yes |
| `ai` (Vercel) | `vercelAIIntegration()` | 10.6.0 | Yes* |
| `@langchain/*` | `langChainIntegration()` | 10.28.0 | Yes |
| `@langchain/langgraph` | `langGraphIntegration()` | 10.28.0 | Yes |
| `@google/genai` | `googleGenAIIntegration()` | 10.28.0 | Yes |

*Vercel AI: 10.6.0+ for Node.js, Cloudflare Workers, Vercel Edge Functions, Bun. 10.12.0+ for Deno. Requires `experimental_telemetry` per-call.

### Python

Integrations auto-enable when the AI package is installed — no extras needed:

| Package | Install | Auto? |
|---------|---------|-------|
| `openai` | `pip install sentry-sdk` | Yes |
| `anthropic` | `pip install sentry-sdk` | Yes |
| `langchain` | `pip install sentry-sdk` | Yes |
| `huggingface_hub` | `pip install sentry-sdk` | Yes |

## JavaScript Configuration

### Auto-enabled integrations (OpenAI, Anthropic, Google GenAI, LangChain)

Just ensure tracing is enabled. To capture prompts/outputs:

```javascript
Sentry.init({
  dsn: "YOUR_DSN",
  tracesSampleRate: 1.0,
  integrations: [
    Sentry.openAIIntegration({ recordInputs: true, recordOutputs: true }),
  ],
});
```

### Next.js OpenAI (additional step required)

For Next.js projects using OpenAI, you must wrap the client:

```javascript
import OpenAI from "openai";
import * as Sentry from "@sentry/nextjs";

const openai = Sentry.instrumentOpenAiClient(new OpenAI());
// Use 'openai' client as normal
```

### LangChain / LangGraph (auto-enabled)

```javascript
integrations: [
  Sentry.langChainIntegration({ recordInputs: true, recordOutputs: true }),
  Sentry.langGraphIntegration({ recordInputs: true, recordOutputs: true }),
],
```

### Vercel AI SDK

Add to `sentry.edge.config.ts` for Edge runtime:
```javascript
integrations: [Sentry.vercelAIIntegration()],
```

Enable telemetry per-call:
```javascript
await generateText({
  model: openai("gpt-4o"),
  prompt: "Hello",
  experimental_telemetry: { isEnabled: true, recordInputs: true, recordOutputs: true },
});
```

## Python Configuration

```python
import sentry_sdk
from sentry_sdk.integrations.openai import OpenAIIntegration  # or anthropic, langchain

sentry_sdk.init(
    dsn="YOUR_DSN",
    traces_sample_rate=1.0,
    send_default_pii=True,  # Required for prompt capture
    integrations=[OpenAIIntegration(include_prompts=True)],
)
```

## Manual Instrumentation

Use when no supported SDK is detected.

### Span Types

| `op` Value | Purpose |
|------------|---------|
| `gen_ai.request` | Individual LLM calls |
| `gen_ai.invoke_agent` | Agent execution lifecycle |
| `gen_ai.execute_tool` | Tool/function calls |
| `gen_ai.handoff` | Agent-to-agent transitions |

### Example (JavaScript)

```javascript
await Sentry.startSpan({
  op: "gen_ai.request",
  name: "LLM request gpt-4o",
  attributes: { "gen_ai.request.model": "gpt-4o" },
}, async (span) => {
  span.setAttribute("gen_ai.request.messages", JSON.stringify(messages));
  const result = await llmClient.complete(prompt);
  span.setAttribute("gen_ai.usage.input_tokens", result.inputTokens);
  span.setAttribute("gen_ai.usage.output_tokens", result.outputTokens);
  return result;
});
```

### Key Attributes

| Attribute | Description |
|-----------|-------------|
| `gen_ai.request.model` | Model identifier |
| `gen_ai.request.messages` | JSON input messages |
| `gen_ai.usage.input_tokens` | Input token count |
| `gen_ai.usage.output_tokens` | Output token count |
| `gen_ai.agent.name` | Agent identifier |
| `gen_ai.tool.name` | Tool identifier |

## PII Considerations

Prompts/outputs are PII. To capture:
- **JS**: `recordInputs: true, recordOutputs: true` per-integration
- **Python**: `include_prompts=True` + `send_default_pii=True`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| AI spans not appearing | Verify `tracesSampleRate > 0`, check SDK version |
| Token counts missing | Some providers don't return tokens for streaming |
| Prompts not captured | Enable `recordInputs`/`include_prompts` |
| Vercel AI not working | Add `experimental_telemetry` to each call |
