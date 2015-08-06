require 'build'
require 'circle_ci_event'
require 'jenkins_event'
require 'repositories/count_synchronizer'
require 'snapshots/build'
require 'snapshots/event_count'

require 'active_record'

module Repositories
  class BuildRepository
    def initialize
      @store = Snapshots::Build
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def builds_for(apps:, at: nil)
      ActiveRecord::Base.transaction do
        {
          builds: builds(apps.values, at),
          events: synchronizer.new_events(up_to: at),
        }
      end
    end

    def update
      synchronizer.update do |event|
        next unless event.is_a?(CircleCiEvent) || event.is_a?(JenkinsEvent)

        store.create(
          success: event.success,
          source: event.source,
          version: event.version,
          event_created_at: event.created_at,
        )
      end
    end

    private

    attr_reader :store, :synchronizer

    def builds(versions, at)
      query = at ? store.arel_table['event_created_at'].lteq(at) : nil
      store.select('DISTINCT ON (version) *').where(
        version: versions,
      ).where(query).order('version, id DESC').map { |d|
        Build.new(d.attributes)
      }
    end
  end
end
