require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'good_job/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SimpleGallery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.middleware.use Rack::RawUpload, paths: ['/photos/upload']

    config.encoding = "utf-8"
    config.generators do |g|
      g.test_framework false
    end

    # config.action_cable.mount_path = '/websocket'
    config.filter_parameters += [:password]
    config.action_controller.permit_all_parameters = true
    config.i18n.default_locale = :de
    config.i18n.available_locales = [:de, :en]
  end
end
