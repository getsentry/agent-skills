# Alerts controller — migrated from Honeybadger to Sentry.
class AlertsController < ApplicationController
  def index
    render json: { status: "ok", monitoring: "sentry" }
  end

  # Honeybadger.notify(e) → Sentry.capture_exception(e)
  def trigger_error
    raise ArgumentError, "invalid alert configuration"
  rescue => e
    Sentry.capture_exception(e)
    render json: { status: "error captured by Sentry" }
  end

  # Honeybadger.notify("message", context: hash) → Sentry.with_scope + capture_message
  def notify_error
    Sentry.with_scope do |scope|
      scope.set_context("alert", { severity: "high", component: "alerts" })
      Sentry.capture_message("Critical system event detected")
    end
    render json: { status: "notified" }
  end
end
