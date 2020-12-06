return if ARGV.join.include?('assets:precompile')

Rails.application.config.to_prepare do
  s = ->(key) {
    setting = begin
                Setting.find_by(var: key)
              rescue ActiveRecord::StatementInvalid
                nil
              end
    if setting
      setting.value
    else
      Setting[key]
    end
  }
  time_zone = s.call('default_timezone')
  Rails.configuration.time_zone = time_zone
  Time.zone = ActiveSupport::TimeZone[Rails.configuration.time_zone]
  CarrierWave.configure do |config|
    # config.aws_credentials = {
    #   access_key_id: s.call('aws.access_key_id'),
    #   secret_access_key: s.call('aws.access_key_secret'),
    #   region: s.call('aws.region'),
    # }
    # config.aws_acl    = s.call('aws.acl')
    # config.aws_bucket = s.call('aws.bucket')
    # config.aws_authenticated_url_expiration = 60 * 60 * 24
    # config.aws_attributes = {
    #   expires: 1.week.from_now.httpdate,
    #   cache_control: 'max-age=604800'
    # }
  end
end
