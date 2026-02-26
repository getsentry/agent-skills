# Metrics — Sentry Ruby SDK

> Minimum SDK: `sentry-ruby` v6.3.0+
> Metrics are enabled by default (`config.enable_metrics = true`). The v6.3.0 release replaced the beta `increment` API with `count`.

## Contents

- [Configuration](#configuration)
- [Metric Types](#metric-types)
- [Unit Reference](#unit-reference)
- [`before_send_metric` Hook](#before_send_metric-hook)
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
Sentry.metrics.gauge("cache.size", Rails.cache.stats[:curr_items])
Sentry.metrics.gauge("connections.active", ActiveRecord::Base.connection_pool.connections.size)
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
