#!/usr/bin/env bash
# tools/reset.sh — Reset all test apps to the pre-Sentry state stored in git.
#
# The committed state of the test apps is the pre-skill baseline. This script
# restores that state so you can re-apply the skill and use `git diff` to see
# exactly what changed.
#
# Safe to run multiple times.
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$(dirname "$TOOLS_DIR")"
REPO_ROOT="$(git -C "$TOOLS_DIR" rev-parse --show-toplevel)"
RUBY="mise exec ruby@3.3.9 --"

echo "==> Restoring pre-skill state from git..."

git -C "$REPO_ROOT" restore -- \
  "$APPS_DIR/rails-app/Gemfile" \
  "$APPS_DIR/sinatra_app.rb" \
  "$APPS_DIR/honeybadger_app/Gemfile" \
  "$APPS_DIR/honeybadger_app/app/controllers/alerts_controller.rb" \
  "$APPS_DIR/honeybadger_app/config/initializers/honeybadger.rb"

echo "==> Removing any generated Sentry initializers..."

rm -f "$APPS_DIR/rails-app/config/initializers/sentry.rb"
rm -f "$APPS_DIR/honeybadger_app/config/initializers/sentry.rb"

echo "==> Reinstalling gems..."

(cd "$APPS_DIR/rails-app"       && $RUBY bundle install --quiet)
(cd "$APPS_DIR/honeybadger_app" && $RUBY bundle install --quiet)

echo ""
echo "All apps reset to pre-skill state."
echo "Apply the sentry-ruby-sdk skill, then:"
echo "  git diff          — see exactly what the skill changed"
echo "  bash tools/validate.sh — verify the instrumentation works"
