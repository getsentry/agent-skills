#!/usr/bin/env bash
# tools/validate.sh — Verify Sentry instrumentation in all three test apps.
#
# Usage:
#   bash tools/validate.sh
#
# The skill must have been run against each app first (sentry.rb present).
#
# ── Validation modes (auto-selected by priority) ──────────────────────────────
#
#   real      SENTRY_DSN is set — events go to your Sentry project.
#             Also enables Spotlight when npx is available (events go to both).
#             Set SENTRY_URL to override the Sentry host (default: https://sentry.io).
#             Use https://us.sentry.io for US region, https://de.sentry.io for EU region.
#             Example:
#               SENTRY_DSN=https://key@oXXX.ingest.us.sentry.io/YYY \
#               SENTRY_ORG=my-org \
#               SENTRY_URL=https://us.sentry.io \
#               bash tools/validate.sh
#
#   spotlight npx is available but SENTRY_DSN is not set.
#             Events go to local Spotlight at http://localhost:8969.
#             config.spotlight = Rails.env.development? fires automatically.
#
#   mock      No npx and no SENTRY_DSN. Pure Ruby fallback, zero external deps.
#
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$(dirname "$TOOLS_DIR")"
RUBY="mise exec ruby@3.3.9 --"

PASS=0; FAIL=0; SKIP=0
SIDECAR_PID=""; APP_PID=""
SENTRY_URL="${SENTRY_URL:-https://sentry.io}"

# ── mode detection ────────────────────────────────────────────────────────────

if [ -n "${SENTRY_DSN:-}" ]; then
  MODE=real
  echo "Mode: real  (DSN: ${SENTRY_DSN:0:40}...)"
  command -v npx &>/dev/null && echo "        + Spotlight enabled (events go to both Sentry and localhost:8969)"
elif command -v npx &>/dev/null; then
  MODE=spotlight
  echo "Mode: spotlight  (browser UI: http://localhost:8969)"
else
  MODE=mock
  MOCK_PORT=9001
  MOCK_DSN="http://test_key@localhost:${MOCK_PORT}/1"
  MOCK_EVENTS="$TOOLS_DIR/.captured_events.json"
  echo "Mode: mock  (no npx, no SENTRY_DSN)"
fi

# ── helpers ───────────────────────────────────────────────────────────────────

cleanup() {
  [ -n "$SIDECAR_PID" ] && kill "$SIDECAR_PID" 2>/dev/null || true
  [ -n "$APP_PID"     ] && kill "$APP_PID"     2>/dev/null || true
  SIDECAR_PID=""; APP_PID=""
}
trap cleanup EXIT

wait_for_url() {
  local url="$1" seconds="${2:-15}"
  for _ in $(seq "$seconds"); do
    curl -sf "$url" > /dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

start_sidecar() {
  case "$MODE" in
    mock)
      rm -f "$MOCK_EVENTS"
      $RUBY ruby "$TOOLS_DIR/sentry_mock.rb" \
        --port "$MOCK_PORT" --output "$MOCK_EVENTS" --timeout 30 \
        > "$TOOLS_DIR/.mock.log" 2>&1 &
      SIDECAR_PID=$!
      sleep 1
      ;;
    spotlight|real)
      if command -v npx &>/dev/null; then
        npx --yes @spotlightjs/spotlight tail traces --format json \
          > "$TOOLS_DIR/.spotlight_events.ndjson" 2>/dev/null &
        SIDECAR_PID=$!
        sleep 2
      fi
      ;;
  esac
}

stop_sidecar() {
  [ -n "$SIDECAR_PID" ] && { kill "$SIDECAR_PID" 2>/dev/null || true; sleep 0.5; }
  SIDECAR_PID=""
}

# Environment variables passed to each app
app_env() {
  case "$MODE" in
    real)
      printf "SENTRY_DSN=%s RAILS_ENV=development RACK_ENV=development" "$SENTRY_DSN"
      ;;
    spotlight)
      printf "RAILS_ENV=development RACK_ENV=development"
      ;;
    mock)
      printf "SENTRY_DSN=%s" "$MOCK_DSN"
      ;;
  esac
}

# Returns 1 if we can assert pass/fail locally (mock or spotlight), 0 if real DSN
can_assert() { [ "$MODE" != "real" ]; }

count_errors() {
  case "$MODE" in
    mock)
      [ -f "$MOCK_EVENTS" ] || { echo 0; return; }
      $RUBY ruby - <<RUBY
require 'json'
events = JSON.parse(File.read('$MOCK_EVENTS')) rescue []
puts events.count { |e| Array(e['types']).include?('event') }
RUBY
      ;;
    spotlight)
      [ -f "$TOOLS_DIR/.spotlight_events.ndjson" ] || { echo 0; return; }
      wc -l < "$TOOLS_DIR/.spotlight_events.ndjson" | tr -d ' '
      ;;
    real)
      echo 1  # assume sent; user verifies in Sentry
      ;;
  esac
}

result() {
  local label="$1" count="$2"
  if can_assert; then
    if [ "$count" -gt 0 ]; then
      printf "  PASS  %s — %s event(s) captured\n" "$label" "$count"
      PASS=$((PASS + 1))
    else
      printf "  FAIL  %s — no events received\n" "$label"
      FAIL=$((FAIL + 1))
    fi
  else
    printf "  SENT  %s — verify in your Sentry project\n" "$label"
    PASS=$((PASS + 1))
  fi
}

run_app() {
  local app_dir="$1" port="$2" log="$3" rackup_args="${4:-}"
  cd "$app_dir"
  env $(app_env) \
    $RUBY bundle exec rackup config.ru -p "$port" -q $rackup_args \
    > "$log" 2>&1 &
  APP_PID=$!
}

# ── 1. rails-app ─────────────────────────────────────────────────────────────

echo ""
echo "=== rails-app ==="

if [ ! -f "$APPS_DIR/rails-app/config/initializers/sentry.rb" ]; then
  echo "  SKIP  config/initializers/sentry.rb not found"
  echo "        Run the sentry-ruby-sdk skill against rails-app first."
  SKIP=$((SKIP + 1))
else
  start_sidecar
  run_app "$APPS_DIR/rails-app" 3001 "$TOOLS_DIR/.rails.log"

  if wait_for_url "http://localhost:3001/"; then
    curl -sf "http://localhost:3001/"      > /dev/null
    curl -sf "http://localhost:3001/"      > /dev/null
    curl -sf "http://localhost:3001/error" > /dev/null 2>&1 || true
    sleep 3
    result "rails-app" "$(count_errors)"
  else
    echo "  FAIL  rails-app did not start (see tools/.rails.log)"
    FAIL=$((FAIL + 1))
  fi

  kill "$APP_PID" 2>/dev/null || true; APP_PID=""
  stop_sidecar
fi

# ── 2. sinatra_app.rb ─────────────────────────────────────────────────────────

echo ""
echo "=== sinatra_app.rb ==="

if ! grep -q "sentry" "$APPS_DIR/sinatra_app.rb" 2>/dev/null; then
  echo "  SKIP  no sentry gem in sinatra_app.rb"
  echo "        Run the sentry-ruby-sdk skill against sinatra_app.rb first."
  SKIP=$((SKIP + 1))
else
  start_sidecar
  env $(app_env) \
    $RUBY ruby "$APPS_DIR/sinatra_app.rb" \
    > "$TOOLS_DIR/.sinatra.log" 2>&1 &
  APP_PID=$!

  if wait_for_url "http://localhost:4567/"; then
    curl -sf "http://localhost:4567/"      > /dev/null
    curl -sf "http://localhost:4567/error" > /dev/null 2>&1 || true
    sleep 3
    result "sinatra_app.rb" "$(count_errors)"
  else
    echo "  FAIL  sinatra_app.rb did not start (see tools/.sinatra.log)"
    FAIL=$((FAIL + 1))
  fi

  kill "$APP_PID" 2>/dev/null || true; APP_PID=""
  stop_sidecar
fi

# ── 3. honeybadger_app (post-migration) ───────────────────────────────────────

echo ""
echo "=== honeybadger_app (post-migration) ==="

if [ ! -f "$APPS_DIR/honeybadger_app/config/initializers/sentry.rb" ]; then
  echo "  SKIP  config/initializers/sentry.rb not found"
  echo "        Run the sentry-ruby-sdk migration skill against honeybadger_app first."
  SKIP=$((SKIP + 1))
else
  start_sidecar
  run_app "$APPS_DIR/honeybadger_app" 3002 "$TOOLS_DIR/.honeybadger_app.log"

  if wait_for_url "http://localhost:3002/"; then
    curl -sf "http://localhost:3002/"              > /dev/null
    curl -sf "http://localhost:3002/trigger_error" > /dev/null 2>&1 || true
    curl -sf "http://localhost:3002/notify_error"  > /dev/null 2>&1 || true
    sleep 3
    result "honeybadger_app (post-migration)" "$(count_errors)"
  else
    echo "  FAIL  honeybadger_app did not start (see tools/.honeybadger_app.log)"
    FAIL=$((FAIL + 1))
  fi

  kill "$APP_PID" 2>/dev/null || true; APP_PID=""
  stop_sidecar
fi

# ── summary ───────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  PASS %-3s  FAIL %-3s  SKIP %-3s\n" "$PASS" "$FAIL" "$SKIP"
if [ "$MODE" = real ]; then
  echo "  Verify events and metrics at ${SENTRY_URL}/organizations/${SENTRY_ORG:-<org>}/"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
