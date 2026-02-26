class ApplicationController < ActionController::API
  before_action :set_sentry_context

  private

  def set_sentry_context
    Sentry.configure_scope do |scope|
      scope.set_context("request", { id: request.request_id, env: Rails.env })
    end
  end
end
