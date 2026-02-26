# Metrics — Sentry Ruby SDK

> Minimum SDK: `sentry-ruby` v6.x+
> Metrics are enabled by default (`config.enable_metrics = true`).

## Contents

- [Configuration](#configuration)
- [Metric Types](#metric-types)
- [Unit Reference](#unit-reference)
- [Sidekiq Metrics](#sidekiq-metrics)
- [Detecting Existing Metric Patterns](#detecting-existing-metric-patterns)
- [`before_send_metric` Hook](#before_send_metric-hook)
- [Dashboard Creation](#dashboard-creation)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Configuration

```ruby
Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  # Metrics on by default. To filter or enrich before sending:
  config.before_send_metric = lambda do |metric|
    return nil if metric.name.start_with?("internal.")
    metric.attributes[:environment] ||= Rails.env
    metric
  end
end
```

## Metric Types

### Counter — occurrence counts

```ruby
Sentry.metrics.count("api.requests", attributes: { endpoint: "/orders", status: "200" })
Sentry.metrics.count("user.signup", attributes: { plan: "pro" })
```

### Gauge — current value (can go up or down)

```ruby
Sentry.metrics.gauge("sidekiq.queue.depth", Sidekiq::Stats.new.enqueued)
Sentry.metrics.gauge("cache.size", Rails.cache.stats[:curr_items])
```

### Distribution — statistical spread of a value

```ruby
Sentry.metrics.distribution("http.response_time", duration_ms, unit: "millisecond",
  attributes: { route: "/api/orders" })
Sentry.metrics.distribution("db.query_time", query_ms, unit: "millisecond",
  attributes: { table: "orders" })
```

## Unit Reference

| Category | Values |
|----------|--------|
| Duration | `"nanosecond"`, `"microsecond"`, `"millisecond"`, `"second"`, `"minute"`, `"hour"` |
| Data | `"byte"`, `"kilobyte"`, `"megabyte"`, `"gigabyte"` |
| Fractions | `"ratio"`, `"percent"` |
| None | `"none"` (default) |

## Sidekiq Metrics

Two complementary approaches cover different aspects of Sidekiq observability:

### Option A — Server middleware (per-job metrics)

A Sidekiq server middleware fires for every job execution — the right tool for job duration, throughput, and error rate broken down by queue and worker class.

```ruby
# lib/sentry_job_metrics.rb
class SentryJobMetrics
  def call(worker, job, queue)
    start = Time.now
    yield
    attrs = { queue: queue, worker: worker.class.name }
    Sentry.metrics.distribution("sidekiq.job.duration",
      (Time.now - start) * 1000, unit: "millisecond", attributes: attrs)
    Sentry.metrics.count("sidekiq.job.success", attributes: attrs)
  rescue => e
    Sentry.metrics.count("sidekiq.job.failure",
      attributes: { queue: queue, worker: worker.class.name })
    raise
  end
end

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SentryJobMetrics
  end
end
```

**What this gives you:** `sidekiq.job.duration` (p50/p95/p99 per queue + worker), `sidekiq.job.success` and `sidekiq.job.failure` counters.

**What it cannot give you:** queue depth, queue latency (oldest job age), retry/dead queue sizes — these are aggregate stats that require polling `Sidekiq::Stats`.

### Option B — Aggregate queue stats (periodic sampling)

For queue depth and latency, poll `Sidekiq::Stats` on a schedule. A lightweight background thread or a recurring Sidekiq job both work:

```ruby
# config/initializers/sentry_sidekiq_stats.rb
Thread.new do
  loop do
    begin
      stats = Sidekiq::Stats.new
      Sentry.metrics.gauge("sidekiq.enqueued",  stats.enqueued)
      Sentry.metrics.gauge("sidekiq.retries",   stats.retry_size)
      Sentry.metrics.gauge("sidekiq.dead",      stats.dead_size)

      Sidekiq::Queue.all.first(10).each do |q|
        attrs = { queue: q.name }
        Sentry.metrics.gauge("sidekiq.queue.depth",   q.size,    attributes: attrs)
        Sentry.metrics.gauge("sidekiq.queue.latency", q.latency,
          unit: "second", attributes: attrs)
      end
    rescue => e
      # don't crash the thread on transient Redis errors
    end
    sleep 30
  end
end
```

**Use both together** for complete Sidekiq visibility: the middleware captures per-job detail, the poller captures queue health over time.

## Detecting Existing Metric Patterns

Before adding Sentry metrics, scan for existing instrumentation to migrate or complement:

```bash
# StatsD / Datadog / Prometheus calls
grep -rE "(statsd|dogstatsd|prometheus|\.gauge|\.distribution|\.histogram|\.increment|\.timing)" \
  app/ lib/ --include="*.rb" | grep -v "_spec\|_test"

# Sidekiq::Stats usage (shows what's already being tracked)
grep -rn "Sidekiq::Stats\|Sidekiq::Queue" app/ lib/ --include="*.rb"
```

## `before_send_metric` Hook

```ruby
config.before_send_metric = lambda do |metric|
  return nil if metric.name.start_with?("internal.")
  metric.attributes.delete(:user_id)  # strip PII
  metric
end
```

`MetricEvent` properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Metric identifier |
| `type` | `Symbol` | `:counter`, `:gauge`, or `:distribution` |
| `value` | `Numeric` | Measurement value |
| `unit` | `String?` | Measurement unit |
| `attributes` | `Hash` | Custom key-value pairs |
| `trace_id` | `String?` | Auto-linked when inside a transaction |

## Dashboard Creation

After Sidekiq metrics have been flowing for a few minutes, create a pre-built dashboard via the Sentry API.

### Prerequisites

```bash
export SENTRY_AUTH_TOKEN=sntrys_...         # org:write scope
export SENTRY_ORG=my-org                    # org slug from Settings → General
export SENTRY_URL=https://us.sentry.io      # or https://de.sentry.io for EU region
```

Widget queries use Sentry's Metric Resource Identifier (MRI) format:

| Type | MRI pattern | Example |
|------|-------------|---------|
| Gauge | `g:custom/<name>@<unit>` | `g:custom/sidekiq.queue.depth@none` |
| Counter | `c:custom/<name>@none` | `c:custom/sidekiq.job.success@none` |
| Distribution | `d:custom/<name>@<unit>` | `d:custom/sidekiq.job.duration@millisecond` |

### Create the dashboard

```bash
curl -sS -X POST "${SENTRY_URL}/api/0/organizations/${SENTRY_ORG}/dashboards/" \
  -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sidekiq Metrics",
    "widgets": [
      {
        "title": "Job Duration (p95)",
        "displayType": "line",
        "widgetType": "metrics",
        "limit": 10,
        "queries": [{
          "name": "",
          "fields": ["p95(d:custom/sidekiq.job.duration@millisecond)"],
          "aggregates": ["p95(d:custom/sidekiq.job.duration@millisecond)"],
          "columns": ["queue"],
          "conditions": "",
          "orderby": ""
        }],
        "layout": {"x": 0, "y": 0, "w": 4, "h": 2, "minH": 2}
      },
      {
        "title": "Job Success vs Failure",
        "displayType": "line",
        "widgetType": "metrics",
        "limit": 10,
        "queries": [
          {
            "name": "Success",
            "fields": ["sum(c:custom/sidekiq.job.success@none)"],
            "aggregates": ["sum(c:custom/sidekiq.job.success@none)"],
            "columns": [],
            "conditions": "",
            "orderby": ""
          },
          {
            "name": "Failure",
            "fields": ["sum(c:custom/sidekiq.job.failure@none)"],
            "aggregates": ["sum(c:custom/sidekiq.job.failure@none)"],
            "columns": [],
            "conditions": "",
            "orderby": ""
          }
        ],
        "layout": {"x": 4, "y": 0, "w": 4, "h": 2, "minH": 2}
      },
      {
        "title": "Queue Depth by Queue",
        "displayType": "line",
        "widgetType": "metrics",
        "limit": 10,
        "queries": [{
          "name": "",
          "fields": ["max(g:custom/sidekiq.queue.depth@none)"],
          "aggregates": ["max(g:custom/sidekiq.queue.depth@none)"],
          "columns": ["queue"],
          "conditions": "",
          "orderby": ""
        }],
        "layout": {"x": 0, "y": 2, "w": 4, "h": 2, "minH": 2}
      },
      {
        "title": "Queue Latency by Queue",
        "displayType": "line",
        "widgetType": "metrics",
        "limit": 10,
        "queries": [{
          "name": "",
          "fields": ["max(g:custom/sidekiq.queue.latency@second)"],
          "aggregates": ["max(g:custom/sidekiq.queue.latency@second)"],
          "columns": ["queue"],
          "conditions": "",
          "orderby": ""
        }],
        "layout": {"x": 4, "y": 2, "w": 4, "h": 2, "minH": 2}
      },
      {
        "title": "Dead / Retry Queue Size",
        "displayType": "line",
        "widgetType": "metrics",
        "limit": 10,
        "queries": [
          {
            "name": "Dead",
            "fields": ["max(g:custom/sidekiq.dead@none)"],
            "aggregates": ["max(g:custom/sidekiq.dead@none)"],
            "columns": [],
            "conditions": "",
            "orderby": ""
          },
          {
            "name": "Retries",
            "fields": ["max(g:custom/sidekiq.retries@none)"],
            "aggregates": ["max(g:custom/sidekiq.retries@none)"],
            "columns": [],
            "conditions": "",
            "orderby": ""
          }
        ],
        "layout": {"x": 8, "y": 2, "w": 4, "h": 2, "minH": 2}
      }
    ]
  }' | ruby -r json -e \
  'r=JSON.parse($stdin.read); puts "'${SENTRY_URL}'/organizations/'${SENTRY_ORG}'/dashboards/#{r["id"]}/"'
```

Verify metric names are arriving first: **Dashboards → Add Widget → Metrics** — the picker shows exactly what the SDK has sent.

## Best Practices

- Use `count` for events, `gauge` for current state, `distribution` for latency/sizes
- Always set `unit:` on distributions — enables proper chart rendering
- Use `attributes:` to slice by queue name, route, status code — these become filter dimensions
- Use `before_send_metric` to strip PII (user IDs, email addresses) from attribute values
- Metrics emitted inside a Sentry transaction are trace-linked automatically

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Metrics not in Sentry | Verify `enable_metrics` is not `false`; check DSN |
| `count` values look wrong | Sentry diffs lifetime counters — reporting deltas directly avoids confusion |
| `before_send_metric` not filtering | Return `nil`, not `false`, to drop a metric |
| Per-job breakdown missing | Ensure `SentryJobMetrics` middleware is added to `server_middleware`, not `client_middleware` |
| Queue depth always zero | Verify the stats polling thread is running; check Redis connectivity |
