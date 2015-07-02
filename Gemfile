source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '~> 4.2.1'

gem 'addressable', require: 'addressable/uri'
gem 'bootstrap-sass'
gem 'dotenv'
gem 'haml-rails'
gem 'has_secure_token'
gem 'jquery-rails'
gem 'newrelic_rpm'
gem 'omniauth'
gem 'omniauth-auth0'
gem 'pg'
gem 'rack-timeout'
gem 'rugged', '~> 0.23.0b4' # We need Rugged::Repository#descendant_of?
gem 'sass-rails'
gem 'therubyracer'
gem 'uglifier'
gem 'unicorn'
gem 'unicorn-rails'
gem 'virtus'

group :development do
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard'
  gem 'pry-rails'
  gem 'spring'
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rubocop'
end

group :production do
  gem 'rails_12factor'
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'launchy'
  gem 'rack-test', require: 'rack/test'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
