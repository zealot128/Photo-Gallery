CarrierWave.configure do |config|
  config.aws_credentials = {
    :access_key_id      => Setting['aws.access_key_id'],
    :secret_access_key  => Setting['aws.access_key_secret'],
    :region             => Setting['aws.region'],
  }
  config.aws_acl    = Setting['aws.acl']
  config.aws_bucket = Setting['aws.bucket']
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
  config.aws_attributes = {
    expires: 1.week.from_now.httpdate,
    cache_control: 'max-age=604800'
  }
end

