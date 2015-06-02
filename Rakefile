# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task default: [:spec, :cucumber, :rubocop]

task :codeclimate do
  require 'simplecov'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter::Formatter.new.format(SimpleCov.result)
end

namespace :heroku do
  desc 'Replace local database with Herokus one'
  task pull: :environment do
    fail "Halting to prevent dropping '#{Rails.env}'" unless Rails.env.development?

    config   = Rails.configuration.database_configuration.fetch(Rails.env)
    database = config['database']

    ENV['RAILS_ENV'] = 'development'
    Rake::Task['db:drop'].invoke

    sh "heroku pg:pull DATABASE_URL #{database}"
  end
end
