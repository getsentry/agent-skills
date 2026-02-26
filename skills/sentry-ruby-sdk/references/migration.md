# Migrating to Sentry — Ruby SDK

> Covers migrations from: AppSignal, Honeybadger

## Contents

- [Step 1: Detect What's in the Codebase](#step-1-detect-whats-in-the-codebase)
- [AppSignal → Sentry](#appsignal--sentry)
- [Honeybadger → Sentry](#honeybadger--sentry)
- [Universal Migration Checklist](#universal-migration-checklist)
- [Troubleshooting](#troubleshooting)

## Step 1: Detect What's in the Codebase

```bash
# Find competitor gems
grep -E '"appsignal"|"honeybadger"' Gemfile Gemfile.lock 2>/dev/null

# Find call sites across the app
grep -rn "Appsignal\.\|Honeybadger\." \
  app/ lib/ config/ --include="*.rb" | grep -v "_spec\|_test"

# Find config files to remove after migration
ls config/appsignal.yml \
   config/honeybadger.yml .honeybadger.yml 2>/dev/null
```

---

## AppSignal → Sentry

**Gemfile:**
```ruby
# Remove:
gem "appsignal"

# Add:
gem "sentry-ruby"
gem "sentry-rails"     # if Rails
gem "sentry-sidekiq"   # if Sidekiq
```

**Delete:** `config/appsignal.yml`, `config/initializers/appsignal.rb`

### API mapping

| AppSignal | Sentry |
|-----------|--------|
| `Appsignal.report_error(e)` | `Sentry.capture_exception(e)` |
| `Appsignal.send_error(e)` | `Sentry.capture_exception(e)` |
| `Appsignal.set_error(e)` | `Sentry.capture_exception(e)` |
| `Appsignal.listen_for_error { }` | `begin … rescue => e; Sentry.capture_exception(e); raise; end` |
| `Appsignal.tag_request(key: val)` | `Sentry.set_tags(key: val)` |
| `Appsignal.add_tags(key: val)` | `Sentry.set_tags(key: val)` |
| `Appsignal.add_custom_data(hash)` | `Sentry.set_context("custom", hash)` |
| `Appsignal.set_action("name")` | `Sentry.get_current_scope.set_transaction_name("name")` |
| `Appsignal.add_breadcrumb(cat, action, msg)` | `Sentry.add_breadcrumb(Sentry::Breadcrumb.new(category: cat, message: msg))` |
| `Appsignal.instrument("name") { }` | `Sentry.with_child_span(op: "name") { }` |
| `Appsignal.set_gauge("m", val, tags)` | `Sentry.metrics.gauge("m", val, attributes: tags)` |
| `Appsignal.increment_counter("m", val, tags)` | `Sentry.metrics.count("m", value: val, attributes: tags)` |

### Find call sites

```bash
grep -rn "Appsignal\.\(report_error\|send_error\|set_error\|listen_for_error\|tag_request\|add_tags\|add_custom_data\|instrument\|set_gauge\|increment_counter\)" \
  app/ lib/ --include="*.rb"
```

### Initializer

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
  config.enable_logs = true
end
```

---

## Honeybadger → Sentry

**Gemfile:**
```ruby
# Remove:
gem "honeybadger"

# Add:
gem "sentry-ruby"
gem "sentry-rails"
```

**Delete:** `config/honeybadger.yml`, `.honeybadger.yml`

### API mapping

| Honeybadger | Sentry |
|-------------|--------|
| `Honeybadger.notify(e)` | `Sentry.capture_exception(e)` |
| `Honeybadger.notify("message")` | `Sentry.capture_message("message")` |
| `Honeybadger.notify(e, context: hash)` | `Sentry.with_scope { \|s\| s.set_context("ctx", hash); Sentry.capture_exception(e) }` |
| `Honeybadger.context(key: val)` | `Sentry.set_tags(key: val)` |
| `Honeybadger.context { \|c\| c[:key] = val }` | `Sentry.configure_scope { \|s\| s.set_context("app", {key: val}) }` |
| `Honeybadger.context.clear!` | `Sentry.get_current_scope.clear` |
| `Honeybadger.add_breadcrumb(msg, metadata: h)` | `Sentry.add_breadcrumb(Sentry::Breadcrumb.new(message: msg, data: h))` |
| `Honeybadger.exception_filter { \|n\| n.halt! if … }` | `config.before_send = lambda { \|e, _h\| nil if … }` |

### Find call sites

```bash
grep -rn "Honeybadger\.\(notify\|context\|add_breadcrumb\|exception_filter\)" \
  app/ lib/ --include="*.rb"
```

---

## Universal Migration Checklist

Works for any tool not covered above:

```bash
# Error capture
grep -rn "\.\(notify\|report_error\|send_error\|notice_error\)" \
  app/ lib/ --include="*.rb" | grep -v "_spec\|_test"

# Context / tagging
grep -rn "\.\(context\|tag_request\|add_tags\|add_custom_attributes\)" \
  app/ lib/ --include="*.rb" | grep -v "_spec\|_test"

# Custom spans / instrumentation
grep -rn "\.\(instrument\|monitor\|in_transaction\)" \
  app/ lib/ --include="*.rb" | grep -v "_spec\|_test"

# Metric calls
grep -rn "\.\(set_gauge\|increment_counter\|record_metric\|gauge\|histogram\|timing\)" \
  app/ lib/ --include="*.rb" | grep -v "_spec\|_test"

# Environment variables to update
grep -rn "APPSIGNAL\|HONEYBADGER" \
  .env .env.* config/ --include="*.rb" --include="*.yml" 2>/dev/null
```

### Environment variable mapping

| Tool | Old env var | Sentry |
|------|-------------|--------|
| AppSignal | `APPSIGNAL_PUSH_API_KEY` | `SENTRY_DSN` |
| Honeybadger | `HONEYBADGER_API_KEY` | `SENTRY_DSN` |

### Rollout strategy

Run both tools in parallel for one release cycle, then remove the old gem once Sentry is receiving events in production.

```ruby
# Temporary dual-capture shim — remove after rollout validation:
module ErrorCapture
  def self.capture(exception, context: {})
    Sentry.with_scope do |scope|
      scope.set_context("extra", context) unless context.empty?
      Sentry.capture_exception(exception)
    end
    OldTool.notify(exception) rescue nil  # replace OldTool with actual constant
  end
end
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Missing errors after migration | Ensure `sentry-rails` is present — `sentry-ruby` alone doesn't hook Rails error handlers |
| Context missing from events | Old tools often set context via middleware; replicate with a `before_action` calling `Sentry.set_user` / `Sentry.set_tags` |
| Old gem still loading | Check `Gemfile.lock` — it may be a transitive dependency |
| Distributed traces broken | Ensure all services have migrated and propagate `sentry-trace` + `baggage` headers |
