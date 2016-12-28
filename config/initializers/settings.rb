Rails.configuration.time_zone = Setting['default_timezone']
Time.zone = ActiveSupport::TimeZone[Rails.configuration.time_zone]
