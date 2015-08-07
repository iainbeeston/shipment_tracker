require 'active_record'

module Workers
  class WorkerLock < ActiveRecord::Base; end

  class Updater
    def initialize(repository_updater=Repositories::Updater.from_rails_config)
      @repository_updater = repository_updater
    end

    def run
      puts "Thread #{Thread.current.object_id}"
      begin
        lock_row = WorkerLock.find_or_create_by(name: name)
        lock_row.lock!
      rescue ActiveRecord::ConnectionTimeoutError
        # Another worker has the lock - retry in a bit
        sleep 5
        retry
      end

      puts "Run #{Thread.current.object_id}"
      repository_updater.run
      sleep 60
      puts "Done #{Thread.current.object_id}"
    end

    private

    attr_reader :repository_updater

    def name
      'updater'
    end
  end
end
