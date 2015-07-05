def load_fog(fog)
  require 'fog/aws/storage'
  ENV['AWS_REGION']            = fog.fetch('region')
  ENV['AWS_ACCESS_KEY_ID']     = fog.fetch('aws_access_key_id')
  ENV['AWS_SECRET_ACCESS_KEY'] = fog.fetch('aws_secret_access_key')
  require 'fog'

  Excon.defaults[:write_timeout] = 700
  Excon.defaults[:read_timeout] = 700

  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider => 'AWS',
      :aws_access_key_id      => fog.fetch('aws_access_key_id'),
      :aws_secret_access_key  => fog.fetch('aws_secret_access_key'),
      persistent: false,
      :region                 => fog.fetch('region'),
      # :host                 => 's3.eu-central-1.amazonaws.com',
      # :endpoint             => 'https://s3.example.com:8080' # optional, defaults to nil
    }
    # config.aws_authenticated_url_expiration = 60 * 60 * 24 * 2
    # config.aws_acl    = :public_read
    config.fog_public     = false
    config.fog_directory  = fog.fetch('bucket')
    config.fog_attributes = {'Cache-Control'=>"max-age=#{365.day.to_i}", 'x-amz-acl' => 'public-read'}
  end
end

if Rails.application.secrets.storage == 'aws'
  load_fog(Rails.application.secrets.fog)
end
