# frozen_string_literal: true
#
# Minimal Sinatra test app — Sentry installed (post-skill state).
# Run: ruby sinatra_app.rb
#
# NOTE: Phase 1 detection greps this file, not a separate Gemfile.
# The skill agent should scan *.rb files when no Gemfile is present:
#   grep -E '"sinatra"|"rack"' test-apps/sinatra_app.rb

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "sinatra",    "~> 4.0"
  gem "puma"
  gem "rackup"
  gem "sentry-ruby"
end

require "sentry-ruby"
require "puma"
require "sinatra"
require "json"

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.spotlight = ENV["RACK_ENV"] == "development"
  config.breadcrumbs_logger = [:sentry_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
  config.enable_logs = true
  # OpenSSL 3.5 on Homebrew macOS triggers CRL checking when Net::HTTP calls
  # set_default_paths internally. Specifying the CA file explicitly bypasses
  # that code path and avoids SSL_connect CRL errors.
  config.transport.ssl_ca_file = OpenSSL::X509::DEFAULT_CERT_FILE
end

use Sentry::Rack::CaptureExceptions

set :port, 4567

get "/" do
  content_type :json
  { message: "Hello from Sinatra test app", timestamp: Time.now }.to_json
end

get "/error" do
  raise RuntimeError, "Test error — Sentry should capture this"
end

# bundler/inline changes the caller context, so Sinatra's run? check returns
# false. Explicitly call run! to start the server.
Sinatra::Application.run!
