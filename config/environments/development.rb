Pluie::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  #defined default url options in your environments files
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  #Secret key base
  config.secret_key_base = '4c6ff30c61ca1bef1726dc803bfee01cdda84d169b9b052bdedd4258089fc4109ba285ad7bda391fc7809bb50fc7113b4960bd162979b93ebf87e9ac
  637dcaa5'

  Paperclip.options[:command_path] = "/usr/bin/"

  USE_EM_PROXY = false
end
