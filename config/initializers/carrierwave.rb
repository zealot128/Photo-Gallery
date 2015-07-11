def load_fog(fog)
  # ENV['AWS_REGION']            = fog.fetch('region')
  # ENV['AWS_ACCESS_KEY_ID']     = fog.fetch('aws_access_key_id')
  # ENV['AWS_SECRET_ACCESS_KEY'] = fog.fetch('aws_secret_access_key')


  CarrierWave.configure do |config|
    config.aws_credentials = {
      :access_key_id      => fog.fetch('aws_access_key_id'),
      :secret_access_key  => fog.fetch('aws_secret_access_key'),
      :region             => fog.fetch('region'),
    }
    config.aws_acl    = 'public-read'
    config.aws_bucket     = fog.fetch('bucket')
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
    config.aws_attributes = {
      expires: 1.week.from_now.httpdate,
      cache_control: 'max-age=604800'
    }
  end
end

if Rails.application.secrets.storage == 'aws'
  load_fog(Rails.application.secrets.fog)
end
