# frozen_string_literal: true
#
# Minimal Sinatra test app — pre-Sentry state.
# Run: ruby sinatra_app.rb
#
# NOTE: Phase 1 detection greps this file for framework/gem detection.
# The skill agent should scan *.rb files when no Gemfile is present:
#   grep -E '"sinatra"|"rack"' sinatra_app.rb

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "sinatra", "~> 4.0"
  gem "puma"
  gem "rackup"
end

require "sinatra"
require "json"

set :port, 4567

get "/" do
  content_type :json
  { message: "Hello from Sinatra test app", timestamp: Time.now }.to_json
end

get "/error" do
  raise RuntimeError, "Test error — not yet captured"
end

Sinatra::Application.run!
