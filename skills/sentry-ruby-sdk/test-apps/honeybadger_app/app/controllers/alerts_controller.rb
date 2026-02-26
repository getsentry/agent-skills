class AlertsController < ApplicationController
  def index
    render json: { status: "ok", monitoring: "honeybadger" }
  end

  def trigger_error
    raise ArgumentError, "invalid alert configuration"
  rescue => e
    Honeybadger.notify(e)
    render json: { status: "error captured" }
  end

  def notify_error
    Honeybadger.notify(
      "Critical system event detected",
      context: { severity: "high", component: "alerts" }
    )
    render json: { status: "notified" }
  end
end
