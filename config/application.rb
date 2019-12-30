require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
# require 'action_mailer/railtie'
require 'active_job/railtie'
# require 'action_cable/engine'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module SimpleGallery
  class Application < Rails::Application
    config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.

    config.middleware.use Rack::RawUpload, paths: ['/photos/upload']

    config.encoding = "utf-8"
    config.generators do |g|
      g.test_framework false
    end

    # config.action_cable.mount_path = '/websocket'
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('node_modules')
    config.assets.version = '1.0'
    config.assets.quiet = true
    config.action_controller.permit_all_parameters = true
    config.i18n.default_locale = :de
    config.i18n.available_locales = [:de, :en]
  end
end
