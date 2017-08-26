unless Rails.env.test?
  begin
    LoggingEntry.count
    Rails.logger = LoggingEntry::LoggerProxy.new(nil, 0)
    ActiveSupport::Reloader.to_prepare do
      Rails.logger = LoggingEntry::LoggerProxy.new(nil, 0)
    end
  rescue StandardError
  end
end
require 'silencer/logger'

Rails.application.configure do
  config.middleware.swap Rails::Rack::Logger, Silencer::Logger, silence: [%r{(^/assets/|^/photos)}]
end
