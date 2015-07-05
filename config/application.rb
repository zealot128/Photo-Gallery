require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

module SimpleGallery
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.

    config.middleware.use 'Rack::RawUpload', :paths => ['/photos/upload']

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Europe/Berlin'


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
  end
end
