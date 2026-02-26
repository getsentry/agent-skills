require_relative "boot"

require "rails"
require "action_controller/railtie"
require "active_support/railtie"

Bundler.require(*Rails.groups)

module HoneybadgerApp
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.eager_load = false
    config.secret_key_base = "dev-only-not-for-production"
    config.logger = Logger.new($stdout)
    config.log_level = :info
  end
end
