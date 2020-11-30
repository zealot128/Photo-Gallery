Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environments = %w[production]
  config.open_timeout = 20
  config.timeout = 10
end
