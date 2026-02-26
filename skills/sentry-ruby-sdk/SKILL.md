---
name: sentry-ruby-sdk
description: Full Sentry SDK setup for Ruby. Use when asked to add Sentry to Ruby, install sentry-ruby, setup Sentry in Rails/Sinatra/Rack, or configure error monitoring, tracing, logging, or metrics for Ruby applications. Also handles migration from AppSignal or Honeybadger. Supports Rails, Sinatra, Rack, Sidekiq, and Resque.
license: Apache-2.0
---

# Sentry Ruby SDK

Opinionated wizard that scans the project and guides through complete Sentry setup.

> APIs below reflect sentry-ruby v6.x. Verify against [docs.sentry.io/platforms/ruby/](https://docs.sentry.io/platforms/ruby/) before implementing.

---

## Phase 1: Detect

```bash
# Existing Sentry gems
grep -i sentry Gemfile 2>/dev/null

# Framework
grep -E '"rails"|"sinatra"' Gemfile 2>/dev/null

# Background jobs
grep -E '"sidekiq"|"resque"|"delayed_job"' Gemfile 2>/dev/null

# Competitor monitoring tools — triggers migration path if found
grep -E '"appsignal"|"honeybadger"' Gemfile 2>/dev/null

# Existing metric patterns (StatsD, Datadog, Prometheus)
grep -rE "(statsd|dogstatsd|prometheus|\.gauge|\.histogram|\.increment|\.timing)" \
  app/ lib/ --include="*.rb" 2>/dev/null | grep -v "_spec\|_test" | head -20

# Companion frontend
cat package.json frontend/package.json web/package.json 2>/dev/null | grep -E '"@sentry|"sentry-'
```

**Route from what you find:**
- **Competitor detected** (`appsignal`, `honeybadger`) → load `references/migration.md` first
- **Sentry already present** → skip to Phase 2 to configure features
- **Rails** → use `sentry-rails` + `config/initializers/sentry.rb`
- **Rack/Sinatra** → `sentry-ruby` + `Sentry::Rack::CaptureExceptions` middleware
- **Sidekiq** → add `sentry-sidekiq`; recommend Metrics if existing metric patterns found

---

## Phase 2: Recommend

Lead with a concrete proposal — don't ask open-ended questions:

| Feature | Recommend when... |
|---------|------------------|
| Error Monitoring | **Always** |
| Tracing | Rails / Sinatra / Rack / any HTTP framework |
| Logging | **Always** — `enable_logs: true` costs nothing |
| Metrics | Sidekiq present; existing metric lib (StatsD, Prometheus) detected |

Propose: *"I recommend Error Monitoring + Tracing + Logging [+ Metrics if applicable]. Shall I proceed?"*

---

## Phase 3: Guide

### Install

**Rails:**
```ruby
# Gemfile
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"      # if using Sidekiq
gem "sentry-resque"       # if using Resque
gem "sentry-delayed_job"  # if using DelayedJob
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

### Init — Sidekiq standalone

```ruby
require "sentry-ruby"
require "sentry-sidekiq"

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.spotlight = ENV.fetch("RAILS_ENV", "development") == "development"
  config.breadcrumbs_logger = [:sentry_logger]
  config.traces_sample_rate = 1.0
  config.enable_logs = true
end
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
| Migration | `references/migration.md` | Competitor gem found — load **before** installing Sentry |
| Error Monitoring | `references/error-monitoring.md` | Always |
| Tracing | `references/tracing.md` | HTTP handlers / distributed tracing |
| Logging | `references/logging.md` | Structured log capture |
| Metrics | `references/metrics.md` | Sidekiq present; existing metric patterns |

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
| Sidekiq jobs not traced | Add `sentry-sidekiq` gem |
| Missing request context | Set `config.send_default_pii = true` |
| Logs not appearing | Set `config.enable_logs = true`; sentry-ruby ≥ 5.24.0 required |
| Metrics not appearing | Check `enable_metrics` is not `false`; verify DSN |
