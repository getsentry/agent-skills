# Crons — Sentry Ruby SDK

> Minimum SDK: `sentry-ruby` v5.14.0+

Cron monitoring detects missed, failed, or slow scheduled jobs by capturing check-in events at job start and completion. Each check-in pair creates a monitor timeline in Sentry — if the `:ok` check-in doesn't arrive on time, Sentry raises an alert.

## Contents

- [Manual check-ins](#manual-check-ins)
- [ActiveJob integration](#activejob-integration)
- [Upserting monitor configuration](#upserting-monitor-configuration)
- [Heartbeat pattern](#heartbeat-pattern)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Manual Check-Ins

Use when the scheduler is Clockwork, Whenever, a plain Ruby loop, or any framework without a built-in integration:

```ruby
# Start check-in — save the returned ID
check_in_id = Sentry.capture_check_in("daily-report", :in_progress)

begin
  GenerateDailyReport.run
  Sentry.capture_check_in("daily-report", :ok, check_in_id: check_in_id)
rescue => e
  Sentry.capture_check_in("daily-report", :error, check_in_id: check_in_id)
  Sentry.capture_exception(e)
  raise
end
```

**Monitor slug** must match the slug configured in Sentry. Slugs are unique per project and environment.

**Status values:**

| Status | When to use |
|--------|-------------|
| `:in_progress` | Job has started |
| `:ok` | Job completed successfully |
| `:error` | Job failed |

## ActiveJob Integration

Include `Sentry::Cron::MonitorCheckIns` to auto-capture check-ins for any ActiveJob:

```ruby
class NightlyCleanupJob < ApplicationJob
  include Sentry::Cron::MonitorCheckIns
  sentry_monitor_check_ins

  def perform
    User.inactive.delete_old_accounts
  end
end
```

Customize the slug and schedule:

```ruby
class NightlyCleanupJob < ApplicationJob
  include Sentry::Cron::MonitorCheckIns
  sentry_monitor_check_ins(
    slug: "nightly-cleanup",
    monitor_config: Sentry::Cron::MonitorConfig.from_crontab(
      "0 2 * * *",
      checkin_margin: 5,   # minutes before marking missed
      max_runtime: 30,     # minutes before marking timed out
      timezone: "UTC"
    )
  )

  def perform
    User.inactive.delete_old_accounts
  end
end
```

## Upserting Monitor Configuration

Pass `monitor_config` in the initial check-in to create or update the monitor definition programmatically (no manual setup in Sentry UI required):

```ruby
monitor_config = Sentry::Cron::MonitorConfig.from_crontab(
  "5 * * * *",       # runs at :05 every hour
  checkin_margin: 5,
  max_runtime: 15,
  timezone: "Europe/Berlin"
)

check_in_id = Sentry.capture_check_in(
  "hourly-sync",
  :in_progress,
  monitor_config: monitor_config
)
# ... do work ...
Sentry.capture_check_in("hourly-sync", :ok, check_in_id: check_in_id)
```

### Schedule Types

**Crontab:**
```ruby
Sentry::Cron::MonitorConfig.from_crontab(
  "0 9 * * 1-5",   # 9am weekdays
  checkin_margin: 10,
  max_runtime: 60,
  timezone: "America/New_York"
)
```

**Interval:**
```ruby
Sentry::Cron::MonitorConfig.from_interval(
  30, :minute,     # every 30 minutes
  checkin_margin: 5,
  max_runtime: 25
)
```

Supported interval units: `:minute`, `:hour`, `:day`, `:week`, `:month`, `:year`

## Heartbeat Pattern

For jobs where only missed-schedule detection matters (not duration), send a single `:ok` check-in at job completion:

```ruby
def run_health_ping
  ping_all_services
  Sentry.capture_check_in("health-ping", :ok)
end
```

Heartbeats detect when a job doesn't run at all but cannot detect runtime overages.

## Best Practices

- Use the two-step `:in_progress` / `:ok` pattern for all long-running jobs — it catches both missed runs and jobs that started but never finished
- Set `checkin_margin` a few minutes above the expected cron interval jitter
- Set `max_runtime` conservatively — it's better to alert early on a runaway job than to miss it
- Use `monitor_config` upsert in the job itself rather than configuring monitors manually in the Sentry UI — this keeps schedule definitions in code
- Ensure `SENTRY_DSN` is set in the environment where cron jobs run (often different from the web process)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Check-ins not appearing | Verify `SENTRY_DSN` is set in the cron job's environment (separate from web server) |
| Monitor shows "missed" immediately | `checkin_margin` too low; increase it to account for scheduler jitter |
| `capture_check_in` returns `nil` | SDK not initialized — ensure `Sentry.init` runs before the job |
| ActiveJob mixin not capturing | Confirm `include Sentry::Cron::MonitorCheckIns` and `sentry_monitor_check_ins` are both present |

| Duplicate check-in pairs | Check that `capture_check_in` is not called in both the mixin and manual code for the same job |
