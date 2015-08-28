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
    Repositories::Updater.from_rails_config.run
    puts "[#{Time.current}] Completed update_events"
  end

  desc 'Continuously updates event cache'
  task update_events_loop: :environment do
    Signal.trap('TERM') do
      warn 'Terminating rake task jobs:update_events_loop...'
      @shutdown = true
    end

    loop do
      break if @shutdown
      start_time = Time.current
      puts "[#{start_time}] Running update_events"
      lowest_event_id = Snapshots::EventCount.all.min_by(&:event_id).try(:event_id).to_i

      Repositories::Updater.from_rails_config.run

      end_time = Time.current
      num_events = Events::BaseEvent.where('id > ?', lowest_event_id).count
      puts "[#{end_time}] Cached #{num_events} events in #{end_time - start_time} seconds"
      break if @shutdown
      sleep 5
    end
  end

  desc 'Update git cache'
  task update_git: :environment do
    manage_pid pid_path_for('jobs_update_git')

    puts "[#{Time.current}] Running update_git"
    git_repository_loader = GitRepositoryLoader.from_rails_config
    GitRepositoryLocation.app_names.each do |repository_name|
      puts "[#{Time.current}] Updating #{repository_name}"
      git_repository_loader.load(repository_name)
    end
    puts "[#{Time.current}] Completed update_git"
  end

  desc 'Clear all Snapshots regenerates from events'
  task clear_snapshots: :environment do
    Snapshots::Build.destroy_all
    Snapshots::Deploy.destroy_all
    Snapshots::FeatureReview.destroy_all
    Snapshots::ManualTest.destroy_all
    Snapshots::Ticket.destroy_all
    Snapshots::Uatest.destroy_all
    Snapshots::EventCount.destroy_all
    puts 'All snapshots cleared'
  end
end
