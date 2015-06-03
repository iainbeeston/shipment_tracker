worker_processes Integer(ENV['WEB_CONCURRENCY'] || 1)
timeout 15
preload_app true

root = File.expand_path('../..', __FILE__)

stderr_path File.join(root, 'log/unicorn.log')
stdout_path File.join(root, 'log/unicorn.log')

pid File.join(root, 'tmp/pids/unicorn.pid')
listen File.join(root, 'tmp/sockets/unicorn.sock'), backlog: 64

before_fork do |_server, _worker|
  Signal.trap 'TERM' do
    Rails.logger.warn 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    Rails.logger.warn 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
