require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module SimpleGallery
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.

    config.middleware.use 'Rack::RawUpload', :paths => ['/photos/upload']

    config.encoding = "utf-8"
    config.generators do |g|
      g.test_framework  false
    end

    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.action_controller.permit_all_parameters = true
    config.active_record.raise_in_transactional_callbacks = true
    config.features = Hashie::Mash.new YAML.load_file 'config/features.yml'
    if config.features.default_timezone
      config.time_zone = config.features.default_timezone
    end
  end
end
