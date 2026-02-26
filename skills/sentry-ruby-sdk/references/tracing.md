# Tracing — Sentry Ruby SDK

> Minimum SDK: `sentry-ruby` v5.10.0+ for distributed tracing out of the box

## Contents

- [Configuration](#configuration)
- [Automatic Instrumentation](#automatic-instrumentation)
- [Custom Instrumentation](#custom-instrumentation)
- [Distributed Tracing](#distributed-tracing)
- [`before_send_transaction` hook](#before_send_transaction-hook)
- [OpenTelemetry Bridge](#opentelemetry-bridge)
- [Framework Auto-Instrumentation Summary](#framework-auto-instrumentation-summary)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Configuration

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `traces_sample_rate` | Float | `nil` | Uniform sample rate [0.0–1.0]; `nil` disables tracing |
| `traces_sampler` | Lambda | `nil` | Custom per-transaction sampling; overrides `traces_sample_rate` |
| `trace_propagation_targets` | Array | `[/.*/]` | URLs to inject `sentry-trace` + `baggage` headers into |
| `propagate_traces` | Boolean | `true` | Propagate trace headers on outbound Net::HTTP requests |

```ruby
Sentry.init do |config|
  config.traces_sample_rate = 1.0  # set to 0.05–0.2 in production

  # — or — per-transaction dynamic sampling:
  config.traces_sampler = lambda do |sampling_context|
    tc = sampling_context[:transaction_context]
    case tc[:op]
    when /http/
      case tc[:name]
      when /health/ then 0.0   # drop health checks
      else               0.1
      end
    when /sidekiq/ then 0.01
    else                0.0
    end
  end
end
```

## Automatic Instrumentation

### Rails (via `sentry-rails`)

No extra code needed. The following are auto-instrumented:

- `ActionController` — one transaction per request
- `ActiveRecord` — SQL queries as child spans
- `ActionMailer` — mail delivery as child spans
- `ActiveJob` — job execution as child spans
- `Net::HTTP` outbound calls — child spans with trace header propagation

### Rack / Sinatra (via `Sentry::Rack::CaptureExceptions`)

```ruby
use Sentry::Rack::CaptureExceptions
```

Wraps each Rack request in a transaction.

### Sidekiq (via `sentry-sidekiq`)

No extra code. Each worker execution becomes a transaction, inheriting distributed trace context from the enqueuing request.

## Custom Instrumentation

### Wrap a block in a child span (preferred)

```ruby
Sentry.with_child_span(op: "process_items", description: "processing order items") do |span|
  span&.set_data(:item_count, items.length)
  span&.set_data(:order_id, order.id)
  order.process_items
end
```

`with_child_span` yields `nil` when not sampling — always guard data calls with `span&.set_data`.

### Child span on an existing transaction

```ruby
transaction = Sentry.get_current_scope.get_transaction
transaction&.with_child_span(op: "cache.fetch", description: "fetch user cache") do |span|
  span&.set_data("cache.key", cache_key)
  Rails.cache.fetch(cache_key) { User.find(user_id) }
end
```

### Manual transaction (only when no automatic transaction wraps the code)

```ruby
transaction = Sentry.start_transaction(
  name: "ProcessBatch",
  op: "background_job",
  sampled: true
)
Sentry.get_current_scope.set_span(transaction)

begin
  process_batch(records)
  transaction.set_status("ok")
rescue => e
  transaction.set_status("internal_error")
  Sentry.capture_exception(e)
  raise
ensure
  transaction.finish
end
```

### Span data conventions

```ruby
Sentry.with_child_span(op: "http.client") do |span|
  span&.set_data("http.method", "POST")
  span&.set_data("http.url", endpoint)
  response = http_client.post(endpoint, body)
  span&.set_data("http.status_code", response.status)
  response
end
```

## Distributed Tracing

Distributed tracing works out of the box for same-process `Net::HTTP` calls — Sentry patches Net::HTTP to inject `sentry-trace` and `baggage` headers automatically.

### Manual header propagation (custom HTTP clients)

```ruby
headers = Sentry.get_trace_propagation_headers
# => { "sentry-trace" => "abc...xyz-1", "baggage" => "sentry-trace_id=abc..." }

faraday_conn.get("/api/orders") do |req|
  headers.each { |k, v| req.headers[k] = v }
end
```

### Frontend trace stitching (Ruby backend → JS frontend)

Inject Sentry trace metadata into your HTML `<head>` so the browser SDK can continue the same trace:

**Rails (`app/views/layouts/application.html.erb`):**

```erb
<head>
  <%= Sentry.get_trace_propagation_meta.html_safe %>
  ...
</head>
```

This renders two `<meta>` tags that `@sentry/browser` (and framework SDKs like `@sentry/react`, `sentry-svelte-sdk`) automatically read on page load. Requires `browserTracingIntegration` on the frontend SDK.

### Inbound trace propagation (accepting from upstream)

Rails and Rack middleware automatically read incoming `sentry-trace` and `baggage` headers and continue the trace — no configuration required.

## `before_send_transaction` hook

```ruby
config.before_send_transaction = lambda do |event, _hint|
  # Drop health check transactions
  if event.transaction&.match?(%r{/health(z|check)?$})
    next nil
  end

  # Scrub sensitive data from DB spans
  event.spans.each do |span|
    if span[:op]&.start_with?("db") && span[:description]&.include?("password")
      span[:description] = "<filtered>"
    end
  end

  event
end
```

## OpenTelemetry Bridge

If your app already uses OpenTelemetry, use `sentry-opentelemetry` to route OTel spans into Sentry:

```ruby
# Gemfile
gem "sentry-opentelemetry"
```

```ruby
Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.traces_sample_rate = 1.0
end

# In your OTel setup:
require "sentry-opentelemetry"
Sentry.init_otel_provider
```

Sentry becomes a Span Exporter and Propagator — existing OTel instrumentation flows through without changes.

## Framework Auto-Instrumentation Summary

| Framework / Library | Gem Required | What's Instrumented |
|--------------------|-------------|---------------------|
| Rails controllers | `sentry-rails` | Requests → transactions; actions → spans |
| ActiveRecord | `sentry-rails` | SQL queries → spans |
| ActionMailer | `sentry-rails` | Mail delivery → spans |
| ActiveJob | `sentry-rails` | Job execution → spans |
| Sidekiq workers | `sentry-sidekiq` | Worker execution → transactions |
| Resque workers | `sentry-resque` | Worker execution → transactions |
| DelayedJob | `sentry-delayed_job` | Job execution → transactions |
| Net::HTTP | `sentry-ruby` | Outbound HTTP → spans + header propagation |
| Redis | `sentry-ruby` | Redis commands → spans (needs `:redis_logger`) |
| GraphQL | `sentry-ruby` | Queries → transactions (enable with `enabled_patches`) |

## Best Practices

- Set `traces_sample_rate = 1.0` in development/staging; use `0.05`–`0.2` in production
- Use `traces_sampler` to exclude health checks and low-value endpoints
- Set `op` to a semantic value: `"http.server"`, `"db.query"`, `"queue.process"`, `"cache.get"`
- Prefer `with_child_span` over manual transaction management — it handles errors and finishing automatically
- Always guard span calls with `span&.set_data` — `with_child_span` yields `nil` when not sampling

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No transactions in dashboard | Set `traces_sample_rate > 0`; ensure `sentry-rails` or Rack middleware is present |
| Sidekiq jobs not traced | Add `sentry-sidekiq` gem; no other config needed |
| Missing DB spans | Ensure `sentry-rails` is loaded (it patches ActiveRecord) |
| Distributed trace not stitching | Verify `sentry-trace` + `baggage` headers are forwarded by all services |
| Frontend trace not linking | Add `<%= Sentry.get_trace_propagation_meta.html_safe %>` to your HTML `<head>` |
| Health check transactions flooding | Use `traces_sampler` to return `0.0` for health check transaction names |
| `before_send_transaction` not filtering | Return `nil` (not `false`) to drop the event |
