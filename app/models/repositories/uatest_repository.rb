require 'repositories/count_synchronizer'
require 'snapshots/event_count'
require 'snapshots/uatest'
require 'uat_event'
require 'uatest'

require 'active_record'

module Repositories
  class UatestRepository
    def initialize(deploy_projection: Projections::DeploysProjection)
      @deploy_projection = deploy_projection
      @store = Snapshots::Uatest
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def uatest_for(apps:, server:, at: nil)
      ActiveRecord::Base.transaction do
        uatest(apps, server, at).merge(events: synchronizer.new_events(up_to: at))
      end
    end

    def update
      synchronizer.update do |event|
        next unless event.is_a?(UatEvent)

        new_uatest = {
          server: event.server,
          success: event.success,
          test_suite_version: event.test_suite_version,
          versions: versions_for(event.server, event.created_at),
          event_created_at: event.created_at,
        }

        store.create(new_uatest)
      end
    end

    private

    attr_reader :store, :synchronizer, :deploy_projection

    def uatest(app_versions, server, at)
      query = at ? store.arel_table['event_created_at'].lteq(at) : nil
      uatest = store
               .where(server: server)
               .where('versions @> ?', app_versions.to_json)
               .where(query)
               .order('id DESC')
               .first

      if uatest
        { uatest: Uatest.new(uatest.attributes), versions: uatest.attributes['versions'] }
      else
        { uatest: nil, versions: {} }
      end
    end

    def versions_for(server, at)
      projection = deploy_projection.load(server: server, at: at)
      projection.deploys.map { |d| [d.app_name, d.version] }.to_h
    end
  end
end
