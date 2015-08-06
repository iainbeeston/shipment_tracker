require 'repositories/deploy_repository'
require 'snapshots/uatest'
require 'uat_event'
require 'uatest'

module Repositories
  class UatestRepository
    def initialize(store = Snapshots::Uatest, deploy_repository: Repositories::DeployRepository.new)
      @store = store
      @deploy_repository = deploy_repository
    end

    delegate :table_name, to: :store

    def uatest_for(apps:, server:, at: nil)
      uatest(apps, server, at)
    end

    def apply(event)
      return unless event.is_a?(UatEvent)

      store.create!(
        server: event.server,
        success: event.success,
        test_suite_version: event.test_suite_version,
        versions: versions_for(event.server, event.created_at),
        event_created_at: event.created_at,
      )
    end

    private

    attr_reader :store, :deploy_repository

    def uatest(app_versions, server, at)
      query = at ? store.arel_table['event_created_at'].lteq(at) : nil
      store
        .where(server: server)
        .where('versions @> ?', app_versions.to_json)
        .where(query)
        .order('id DESC')
        .first
        .try { |r| Uatest.new(r.attributes) }
    end

    def versions_for(server, at)
      deploys = deploy_repository.deploys_for(server: server, at: at)
      deploys.map { |d| [d.app_name, d.version] }.to_h
    end
  end
end
