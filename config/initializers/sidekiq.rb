require 'sidekiq/web'
Sidekiq::Web.app_url = '/'

redis_config = { url: ENV['REDIS_SIDEKIQ_URL'] }

Sidekiq.configure_server do |config|
  if ENV['REDIS_SIDEKIQ_URL']
    config.redis = redis_config
  end
  # Sidekiq::Cron::Job.load_from_hash YAML.load_file('config/schedule.yml')
end
Sidekiq.configure_client do |config|
  if ENV['REDIS_SIDEKIQ_URL']
    config.redis = redis_config
  end
end

if Rails.env.production?
  Sidekiq::Logging.logger = Rails.logger
end
Sidekiq::Web.set :session_secret, Rails.application.secrets.secret_key_base
