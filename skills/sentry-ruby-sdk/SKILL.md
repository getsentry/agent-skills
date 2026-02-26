---
name: sentry-ruby-sdk
description: Full Sentry SDK setup for Ruby. Use when asked to add Sentry to Ruby, install sentry-ruby, setup Sentry in Rails/Sinatra/Rack, or configure error monitoring, tracing, logging, metrics, profiling, or crons for Ruby applications. Supports Rails, Sinatra, and Rack.
license: Apache-2.0
---

# Sentry Ruby SDK

Opinionated wizard that scans the project and guides through complete Sentry setup.

## Invoke This Skill When

- User asks to "add Sentry to Ruby" or "set up Sentry" in a Ruby app
- User wants error monitoring, tracing, logging, metrics, profiling, or crons in Ruby
- User mentions `sentry-ruby`, `sentry-rails`, or the Ruby Sentry SDK
- User wants to monitor exceptions or HTTP requests in Rails/Sinatra

> **Note:** SDK APIs below reflect sentry-ruby v6.4.0.
> Always verify against [docs.sentry.io/platforms/ruby/](https://docs.sentry.io/platforms/ruby/) before implementing.

---

## Phase 1: Detect

```bash
# Existing Sentry gems
grep -i sentry Gemfile 2>/dev/null

# Framework
grep -E '"rails"|"sinatra"' Gemfile 2>/dev/null

# Companion frontend
cat package.json frontend/package.json web/package.json 2>/dev/null | grep -E '"@sentry|"sentry-'
```

**Route from what you find:**
- **Sentry already present** → skip to Phase 2 to configure features
- **Rails** → use `sentry-rails` + `config/initializers/sentry.rb`
- **Rack/Sinatra** → `sentry-ruby` + `Sentry::Rack::CaptureExceptions` middleware

---

## Phase 2: Recommend

Lead with a concrete proposal — don't ask open-ended questions:

| Feature | Recommend when... |
|---------|------------------|
| Error Monitoring | **Always** |
| Tracing | Rails / Sinatra / Rack / any HTTP framework |
| Logging | **Always** — `enable_logs: true` costs nothing |
| Metrics | Business KPIs, SLO tracking, or custom counters needed |
| Profiling | ⚠️ Beta — performance profiling requested; requires `stackprof` or `vernier` gem |
| Crons | Scheduled jobs detected (ActiveJob, Clockwork, Whenever) |

Propose: *"I recommend Error Monitoring + Tracing + Logging [+ Metrics if applicable]. Shall I proceed?"*

---

## Phase 3: Guide

### Install

**Rails:**
```ruby
# Gemfile
gem "sentry-ruby"
gem "sentry-rails"
```

**Rack / Sinatra / plain Ruby:**
```ruby
gem "sentry-ruby"
```

Run `bundle install`.

### Init — Rails (`config/initializers/sentry.rb`)

```ruby
Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.spotlight = Rails.env.development?  # local Spotlight UI; no DSN needed in dev
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0  # lower to 0.05–0.2 in production
  config.enable_logs = true
  # Metrics on by default; disable with: config.enable_metrics = false
end
```

`sentry-rails` auto-instruments ActionController, ActiveRecord, ActiveJob, ActionMailer.

### Init — Rack / Sinatra

```ruby
require "sentry-ruby"

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.spotlight = ENV["RACK_ENV"] == "development"
  config.breadcrumbs_logger = [:sentry_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
  config.enable_logs = true
end

use Sentry::Rack::CaptureExceptions  # in config.ru, before app middleware
```

### Environment variables

```bash
SENTRY_DSN=https://xxx@oYYY.ingest.sentry.io/ZZZ
SENTRY_ENVIRONMENT=production   # overrides RAILS_ENV / RACK_ENV
SENTRY_RELEASE=my-app@1.0.0
```

### Feature reference files

Load each reference when implementing the corresponding feature:

| Feature | Reference | Load when... |
|---------|-----------|-------------|
| Error Monitoring | `references/error-monitoring.md` | Always |
| Tracing | `references/tracing.md` | HTTP handlers / distributed tracing |
| Logging | `references/logging.md` | Structured log capture |
| Metrics | `references/metrics.md` | Business KPIs, SLO tracking |
| Profiling | `references/profiling.md` | Performance profiling requested (beta) |
| Crons | `references/crons.md` | Scheduled jobs detected or requested |

---

## Configuration Reference

### Key `Sentry.init` Options

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `dsn` | String | `nil` | SDK disabled if empty; env: `SENTRY_DSN` |
| `environment` | String | `nil` | e.g., `"production"`; env: `SENTRY_ENVIRONMENT` |
| `release` | String | `nil` | e.g., `"myapp@1.0.0"`; env: `SENTRY_RELEASE` |
| `spotlight` | Boolean | `false` | Send events to Spotlight sidecar (local dev, no DSN needed) |
| `send_default_pii` | Boolean | `false` | Include IP addresses and request headers |
| `sample_rate` | Float | `1.0` | Error event sample rate (0.0–1.0) |
| `traces_sample_rate` | Float | `nil` | Transaction sample rate; `nil` disables tracing |
| `profiles_sample_rate` | Float | `nil` | Profiling rate relative to `traces_sample_rate`; requires `stackprof` or `vernier` |
| `enable_logs` | Boolean | `false` | Enable Sentry structured Logs |
| `enable_metrics` | Boolean | `true` | Enable custom metrics (on by default) |
| `breadcrumbs_logger` | Array | `[]` | Loggers for automatic breadcrumbs (see logging reference) |
| `max_breadcrumbs` | Integer | `100` | Max breadcrumbs per event |
| `debug` | Boolean | `false` | Verbose SDK output to stdout |
| `before_send` | Lambda | `nil` | Mutate or drop error events before sending |
| `before_send_transaction` | Lambda | `nil` | Mutate or drop transaction events before sending |
| `before_send_log` | Lambda | `nil` | Mutate or drop log events before sending |

### Environment Variables

| Variable | Maps to | Purpose |
|----------|---------|---------|
| `SENTRY_DSN` | `dsn` | Data Source Name |
| `SENTRY_RELEASE` | `release` | App version (e.g., `my-app@1.0.0`) |
| `SENTRY_ENVIRONMENT` | `environment` | Deployment environment |

Options set in `Sentry.init` override environment variables.

---

## Verification

**Local dev (no DSN needed) — Spotlight:**
```bash
npx @spotlightjs/spotlight          # browser UI at http://localhost:8969
# or stream events to terminal:
npx @spotlightjs/spotlight tail traces --format json
```
`config.spotlight = Rails.env.development?` (already in the init block above) routes events to the local sidecar automatically.

**With a real DSN:**
```ruby
Sentry.capture_message("Sentry Ruby SDK test")
```

Nothing appears? Set `config.debug = true` and check stdout. Verify DSN format: `https://<key>@o<org>.ingest.sentry.io/<project>`.

---

## Phase 4: Cross-Link

```bash
cat package.json frontend/package.json web/package.json 2>/dev/null | grep -E '"@sentry|"sentry-'
```

| Frontend detected | Suggest |
|-------------------|---------|
| React / Next.js | `sentry-react-setup` |
| Svelte / SvelteKit | `sentry-svelte-sdk` |
| Vue | `@sentry/vue` — [docs.sentry.io/platforms/javascript/guides/vue/](https://docs.sentry.io/platforms/javascript/guides/vue/) |

For trace stitching between Ruby backend and JS frontend, see `references/tracing.md` → "Frontend trace stitching".

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Events not appearing | `config.debug = true`; verify DSN; ensure `Sentry.init` before first request |
| Rails exceptions missing | Must use `sentry-rails` — `sentry-ruby` alone doesn't hook Rails error handlers |
| No traces | Set `traces_sample_rate > 0`; ensure `sentry-rails` or `Sentry::Rack::CaptureExceptions` |
| Missing request context | Set `config.send_default_pii = true` |
| Logs not appearing | Set `config.enable_logs = true`; sentry-ruby ≥ 5.24.0 required |
| Metrics not appearing | Check `enable_metrics` is not `false`; verify DSN |
