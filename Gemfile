source 'https://rubygems.org'



# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Devise
gem 'devise'
gem 'devise-i18n-views'

# Cancan
gem 'cancan'

gem 'select2-rails'

group :development do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  # Better errors & binding of caller
  gem 'better_errors'
  gem 'binding_of_caller'
  # Thin web server
  gem 'thin'
end

group :production do
  #Postgre
  gem 'pg'
end

group :test do
  gem 'minitest-rails'
  gem 'shoulda'
  gem 'webmock'
  gem 'mocha'
  gem 'test_after_commit' # run after_commit callbacks in tests. Needed for Wisper.model
  gem 'minitest-colorize'
  gem 'minitest-rails-capybara'
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
end

#Paperclip
gem 'paperclip'

gem 'nokogiri'

#delayed_job -> async jobs
gem 'delayed_job_active_record'
gem 'daemons'
gem 'delayed-web', github: 'thebestday/delayed-web'

#Paginate
gem 'will_paginate'

gem 'em-http-request'
gem 'httpclient' #for savon gem, througth httpi

gem 'action_smser'

gem 'actionpack-xml_parser' # to parse infobip dlr post

gem 'rails-i18n', '~> 4.0.0' # For 4.0.x

gem 'wisper' #to implement observers
gem 'wisper-activerecord'
gem 'wisper-celluloid' #async processing

gem 'smstools' #GSM text size, and other sms utilities
gem 'savon', '~> 2.8.0'#soap client

#gem 'locale_setter', github: 'jcasimir/locale_setter'
gem 'locale_setter'
gem 'jquery-datetimepicker-rails'
gem 'jquery-ui-rails'

