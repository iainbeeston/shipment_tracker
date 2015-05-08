source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '~> 4.2.1'

gem 'bootstrap-sass'
gem 'haml-rails'
gem 'pg'
gem 'rugged'
gem 'sass-rails'
gem 'virtus'

group :development do
  gem 'spring'
  gem 'guard'
  gem 'guard-rspec'
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
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rack-test', require: 'rack/test'
  gem 'launchy'
  gem 'factory_girl'
  gem 'shoulda-matchers'
end
