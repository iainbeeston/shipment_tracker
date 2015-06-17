source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '~> 4.2.1'

gem 'addressable', require: 'addressable/uri'
gem 'bootstrap-sass'
gem 'dotenv'
gem 'haml-rails'
gem 'newrelic_rpm'
gem 'pg'
gem 'rack-timeout'
gem 'rugged', '~> 0.23.0b2' # We need Rugged::Repository#descendant_of?
gem 'sass-rails'
gem 'unicorn'
gem 'unicorn-rails'
gem 'virtus'

group :development do
  gem 'spring'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-cucumber'
  gem 'terminal-notifier-guard'
  gem 'pry-rails'
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
