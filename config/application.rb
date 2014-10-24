require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pluie
  class Application < Rails::Application
    config.assets.precompile << 'delayed/web/application.css'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('bin', 'locales', '**','*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:en, :de]

    config.before_configuration do
        env_file = File.join(Rails.root, 'config', 'local_env.yml')
        YAML.load(File.open(env_file)).each do |key, value|
            ENV[key.to_s] = value
        end if File.exists?(env_file)
    end

    #Setup actionpack-xml_parser to load xml-encoded post body into params hash
    config.middleware.insert_after ActionDispatch::ParamsParser, ActionDispatch::XmlParamsParser

    #autoload folder for custom jobs
    config.autoload_paths += %W( #{config.root}/app/jobs)
  end
end
