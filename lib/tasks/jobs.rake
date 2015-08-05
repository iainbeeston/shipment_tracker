namespace :jobs do
  def already_running?(pid_path)
    pid = File.read(pid_path)
    Process.kill(0, Integer(pid))
    true
  rescue Errno::ENOENT, Errno::ESRCH
    # no such file or pid
    false
  end

  def manage_pid(pid_path)
    fail "Pid file with running process detected, aborting (#{pid_path})" if already_running?(pid_path)
    puts "Writing pid file to #{pid_path}"
    File.open(pid_path, 'w+') do |f|
      f.write Process.pid
    end
    at_exit do
      File.delete(pid_path)
    end
  end

  def pid_path_for(name)
    require 'tmpdir'
    File.expand_path("#{name}.pid", Dir.tmpdir)
  end

  desc 'Update event cache'
  task update_events: :environment do
    manage_pid pid_path_for('jobs_update_events')

    puts "[#{Time.current}] Running update_events"
    Rails.configuration.repositories.each(&:update)
    puts "[#{Time.current}] Completed update_events"
  end

  desc 'Update git cache'
  task update_git: :environment do
    manage_pid pid_path_for('jobs_update_git')

    puts "[#{Time.current}] Running update_git"
    git_repository_loader = GitRepositoryLoader.from_rails_config
    RepositoryLocation.app_names.each do |repository_name|
      puts "[#{Time.current}] Updating #{repository_name}"
      git_repository_loader.load(repository_name)
    end
    puts "[#{Time.current}] Completed update_git"
  end
end
