ENV['AWS_REGION']            = Rails.application.secrets.fog.fetch('region')
  ENV['AWS_ACCESS_KEY_ID']     = Rails.application.secrets.fog.fetch('aws_access_key_id')
  ENV['AWS_SECRET_ACCESS_KEY'] = Rails.application.secrets.fog.fetch('aws_secret_access_key')
  require 'fog'

Excon.defaults[:write_timeout] = 700
Excon.defaults[:read_timeout] = 700

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider => 'AWS',
    :aws_access_key_id      => Rails.application.secrets.fog.fetch('aws_access_key_id'),
    :aws_secret_access_key  => Rails.application.secrets.fog.fetch('aws_secret_access_key'),
    persistent: false,
    :region                 => Rails.application.secrets.fog.fetch('region'),
    # :host                 => 's3.eu-central-1.amazonaws.com',
    # :endpoint             => 'https://s3.example.com:8080' # optional, defaults to nil
  }

  # config.aws_authenticated_url_expiration = 60 * 60 * 24 * 2
  # config.aws_acl    = :public_read
  config.fog_directory  = Rails.application.secrets.fog.fetch('bucket')
  config.fog_attributes = {'Cache-Control'=>"max-age=#{365.day.to_i}", 'x-amz-acl' => 'public-read'}
  # config.storage = :fog
end
