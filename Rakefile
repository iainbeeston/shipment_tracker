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
  desc 'Replaces local development database with Heroku database'
  task pull: :environment do
    fail "Halting to prevent dropping '#{Rails.env}'" unless Rails.env.development?

    STDOUT.print 'This will overwrite your development DB with the Heroku DB. Are you sure? (Y/n) '
    input = STDIN.gets.strip
    case input
    when 'Y', 'y', ''
      config   = Rails.configuration.database_configuration.fetch(Rails.env)
      database = config['database']

      ENV['RAILS_ENV'] = 'development'
      Rake::Task['db:drop'].invoke

      Bundler.with_clean_env { sh "heroku pg:pull DATABASE_URL #{database}" }
    else
      STDOUT.puts 'Did not overwrite development DB.'
    end
  end
end
