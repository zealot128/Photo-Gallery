Rails.application.config.to_prepare do
  time_zone = Setting.find_by_var('default_timezone').value
  Rails.configuration.time_zone = time_zone
  Time.zone = ActiveSupport::TimeZone[Rails.configuration.time_zone]
  CarrierWave.configure do |config|
    config.aws_credentials = {
      :access_key_id      => Setting.find_by_var( 'aws.access_key_id').value,
      :secret_access_key  => Setting.find_by_var( 'aws.access_key_secret').value,
      :region             => Setting.find_by_var( 'aws.region').value,
    }
    config.aws_acl    = Setting.find_by_var( 'aws.acl').value
    config.aws_bucket = Setting.find_by_var( 'aws.bucket').value
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
    config.aws_attributes = {
      expires: 1.week.from_now.httpdate,
      cache_control: 'max-age=604800'
    }
  end

end
