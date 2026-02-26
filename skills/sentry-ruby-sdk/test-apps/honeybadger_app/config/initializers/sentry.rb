require "openssl"

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.spotlight = Rails.env.development?
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
  config.enable_logs = true
  # OpenSSL 3.5 on Homebrew macOS triggers CRL checking when Net::HTTP calls
  # set_default_paths internally. Specifying the CA file explicitly bypasses
  # that code path and avoids SSL_connect CRL errors.
  config.transport.ssl_ca_file = OpenSSL::X509::DEFAULT_CERT_FILE
end
