#!/usr/bin/env bash
# tools/reset.sh — Reset all test apps to the pre-Sentry state stored in git.
#
# Run before testing the sentry-ruby-sdk skill from a clean starting point.
# Safe to run multiple times.
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$(dirname "$TOOLS_DIR")"
REPO_ROOT="$(git -C "$TOOLS_DIR" rev-parse --show-toplevel)"
RUBY="mise exec ruby@3.3.9 --"

echo "==> Restoring Gemfiles and source files from git..."

git -C "$REPO_ROOT" checkout HEAD -- \
  "$APPS_DIR/rails-app/Gemfile" \
  "$APPS_DIR/sinatra_app.rb" \
  "$APPS_DIR/honeybadger_app/Gemfile" \
  "$APPS_DIR/honeybadger_app/app/controllers/alerts_controller.rb" \
  "$APPS_DIR/honeybadger_app/config/initializers/honeybadger.rb"

echo "==> Removing generated Sentry initializers..."

rm -f "$APPS_DIR/rails-app/config/initializers/sentry.rb"
rm -f "$APPS_DIR/honeybadger_app/config/initializers/sentry.rb"

echo "==> Reinstalling gems..."

(cd "$APPS_DIR/rails-app"       && $RUBY bundle install --quiet)
(cd "$APPS_DIR/honeybadger_app" && $RUBY bundle install --quiet)

echo ""
echo "All apps reset. Pre-Sentry state restored."
echo ""
echo "Next step: run the sentry-ruby-sdk skill against each app, then validate:"
echo "  bash tools/validate.sh"
