workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['MAX_THREADS'] || 1)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  RepositoryLocation.all.pluck(:name).each do |app_name|
    Rails.logger.info "Loading #{app_name}"
    GitRepositoryLoader.from_rails_config.load(app_name)
  end
end
