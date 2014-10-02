# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Turn off auto TLS for e-mail
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = false
