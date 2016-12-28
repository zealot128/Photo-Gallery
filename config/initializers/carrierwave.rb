Rails.application.config.to_prepare do
  s = ->(key) { setting =
                  begin
                    Setting.find_by_var(key)
                  rescue ActiveRecord::StatementInvalid
                  end
                if setting
                  setting.value
                else
                  Setting[key]
                end
  }
  time_zone = s.('default_timezone')
  Rails.configuration.time_zone = time_zone
  Time.zone = ActiveSupport::TimeZone[Rails.configuration.time_zone]
  CarrierWave.configure do |config|
    config.aws_credentials = {
      :access_key_id      => s.( 'aws.access_key_id'),
      :secret_access_key  => s.( 'aws.access_key_secret'),
      :region             => s.( 'aws.region'),
    }
    config.aws_acl    = s.('aws.acl')
    config.aws_bucket = s.('aws.bucket')
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
    config.aws_attributes = {
      expires: 1.week.from_now.httpdate,
      cache_control: 'max-age=604800'
    }
  end

end
