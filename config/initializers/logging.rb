unless Rails.env.test?
  begin
    LoggingEntry.count
    Rails.logger = LoggingEntry::LoggerProxy.new(nil, 0)
  rescue StandardError
  end
end
