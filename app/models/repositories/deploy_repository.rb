require 'deploy_event'
require 'repositories/count_synchronizer'
require 'snapshots/deploy'
require 'snapshots/event_count'

require 'active_record'

module Repositories
  class DeployRepository
    def initialize
      @store = Snapshots::Deploy
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def deploys_for(apps: nil, server:, at: nil)
      ActiveRecord::Base.transaction do
        {
          deploys: deploys(apps, server, at),
          events: synchronizer.new_events(up_to: at),
        }
      end
    end

    def update
      synchronizer.update do |event|
        next unless event.is_a?(DeployEvent)

        store.create(
          app_name: event.app_name,
          server: event.server,
          version: event.version,
          deployed_by: event.deployed_by,
          event_created_at: event.created_at,
        )
      end
    end

    private

    attr_reader :store, :synchronizer

    def deploys(apps, server, at)
      query = store.select('DISTINCT ON (server, app_name) *').where(server: server)
      query = query.where(store.arel_table['event_created_at'].lteq(at)) if at
      query = query.where(store.arel_table['app_name'].in(apps.keys)) if apps
      query.order('server, app_name, id DESC').map { |deploy_record|
        build_deploy(deploy_record.attributes, apps)
      }
    end

    def build_deploy(deploy_attr, apps)
      correct = apps.present? && deploy_attr.fetch('version') == apps[deploy_attr.fetch('app_name')]
      Deploy.new(deploy_attr.merge(correct: correct))
    end
  end
end
