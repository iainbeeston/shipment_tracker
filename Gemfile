source 'https://rubygems.org'
ruby '2.2.0'

gem 'rails', '~> 4.2.1'

gem 'bootstrap-sass'
gem 'haml-rails'
gem 'pg'
gem 'rugged'
gem 'sass-rails'
gem 'virtus'

group :development do
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'guard'
  gem 'guard-rspec'
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
end
