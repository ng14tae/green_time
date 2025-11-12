require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Master key
  # config.require_master_key = true

  # Serve static files if environment variable is set
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # CSS compression handled by Tailwind/postcss
  config.assets.css_compressor = nil
  config.assets.compile = false

  # -----------------------------
  # ドメイン / URL 設定
  # -----------------------------

  # Asset host (CDN / main domain for static assets)
  config.action_controller.asset_host = ENV.fetch("APP_ASSET_HOST", "https://cheers-timer.com")

  # Default URL options
  app_host = ENV.fetch("APP_HOST", "cheers-timer.com")
  app_protocol = ENV.fetch("APP_PROTOCOL", "https")
  Rails.application.routes.default_url_options[:host] = app_host
  Rails.application.routes.default_url_options[:protocol] = app_protocol

  # Allowed hosts (DNS rebinding protection)
  config.hosts << app_host
  config.hosts << "www.#{app_host}" # wwwありも許可

  # Force SSL
  config.force_ssl = true

  # Active Storage
  config.active_storage.service = :local

  # -----------------------------
  # ロギング
  # -----------------------------
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Caching for mailer templates
  config.action_mailer.perform_caching = false

  # I18n fallback
  config.i18n.fallbacks = true

  # Deprecations
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false
end
