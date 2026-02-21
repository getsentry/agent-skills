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

## Prerequisites

AI monitoring requires **tracing enabled** (`tracesSampleRate > 0`).

## Data Capture Warning

**Prompt and output recording captures user content that is likely PII.** Before enabling `recordInputs`/`recordOutputs` (JS) or `include_prompts`/`send_default_pii` (Python), confirm:

- The application's privacy policy permits capturing user prompts and model responses
- Captured data complies with applicable regulations (GDPR, CCPA, etc.)
- Sentry data retention settings are appropriate for the sensitivity of the data

**Ask the user** whether they want prompt/output capture enabled. Do not enable it by default — configure it only when explicitly requested or confirmed. Use `tracesSampleRate: 1.0` only in development; in production, use a lower value or a `tracesSampler` function.

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
| `openai` | `openAIIntegration()` | 10.2.0 | Yes |
| `@anthropic-ai/sdk` | `anthropicAIIntegration()` | 10.12.0 | Yes |
| `ai` (Vercel) | `vercelAIIntegration()` | 10.6.0 | Node only* |
| `@langchain/*` | `langChainIntegration()` | 10.22.0 | Yes |
| `@langchain/langgraph` | `langGraphIntegration()` | 10.25.0 | Yes |
| `@google/genai` | `googleGenAIIntegration()` | 10.14.0 | Yes |

*Vercel AI requires explicit setup for Edge runtime and `experimental_telemetry` per-call.

### Python

| Package | Install | Min SDK |
|---------|---------|---------|
| `openai` | `pip install "sentry-sdk[openai]"` | 2.41.0 |
| `anthropic` | `pip install "sentry-sdk[anthropic]"` | 2.x |
| `langchain` | `pip install "sentry-sdk[langchain]"` | 2.x |
| `huggingface_hub` | `pip install "sentry-sdk[huggingface_hub]"` | 2.x |

## JavaScript Configuration

### Auto-enabled integrations (OpenAI, Anthropic, Google GenAI, LangChain)

Just ensure tracing is enabled. Prompt/output capture is opt-in (see Data Capture Warning):

```javascript
Sentry.init({
  dsn: "YOUR_DSN",
  tracesSampleRate: 1.0, // Lower in production (e.g., 0.1)
  integrations: [
    Sentry.openAIIntegration({
      // Optional — captures prompt/response content (contains user PII)
      // recordInputs: true,
      // recordOutputs: true,
    }),
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

### LangChain / LangGraph (explicit)

```javascript
integrations: [
  Sentry.langChainIntegration({
    // recordInputs: true,  // Opt-in: captures prompt content (PII)
    // recordOutputs: true, // Opt-in: captures response content (PII)
  }),
  Sentry.langGraphIntegration({
    // recordInputs: true,
    // recordOutputs: true,
  }),
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
  experimental_telemetry: {
    isEnabled: true,
    // recordInputs: true,  // Opt-in: captures prompt content (PII)
    // recordOutputs: true, // Opt-in: captures response content (PII)
  },
});
```

## Python Configuration

```python
import sentry_sdk
from sentry_sdk.integrations.openai import OpenAIIntegration  # or anthropic, langchain

sentry_sdk.init(
    dsn="YOUR_DSN",
    traces_sample_rate=1.0,  # Lower in production (e.g., 0.1)
    # send_default_pii=True,  # Opt-in: required for prompt capture (sends user PII)
    integrations=[
        OpenAIIntegration(
            # include_prompts=True,  # Opt-in: captures prompt/response content (PII)
        ),
    ],
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

Prompts and model outputs contain user-generated content and are classified as PII. Capture is **disabled by default** and must be explicitly opted into:

- **JS**: `recordInputs: true, recordOutputs: true` per-integration
- **Python**: `include_prompts=True` + `send_default_pii=True`

Only enable these after confirming with the user that prompt capture is desired and compliant with their data handling requirements.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| AI spans not appearing | Verify `tracesSampleRate > 0`, check SDK version |
| Token counts missing | Some providers don't return tokens for streaming |
| Prompts not captured | Enable `recordInputs`/`include_prompts` |
| Vercel AI not working | Add `experimental_telemetry` to each call |
