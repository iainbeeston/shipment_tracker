module Repositories
  class ManualTestRepository
    def initialize
      @store = Snapshots::ManualTest
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def qa_submission_for(apps:, at: nil)
      ActiveRecord::Base.transaction do
        {
          qa_submission: qa_submission(apps.values, at),
          events: synchronizer.new_events(up_to: at),
        }
      end
    end

    def update
      synchronizer.update do |event|
        next unless event.is_a?(ManualTestEvent)

        store.create(
          email: event.email,
          accepted: event.accepted?,
          comment: event.comment,
          versions: prepared_versions(event.versions),
          created_at: event.created_at,
        )
      end
    end

    private

    attr_reader :store, :synchronizer

    def qa_submission(versions, at)
      query = at ? table['created_at'].lteq(at) : nil
      store
        .where(query)
        .where(table['versions'].eq(prepared_versions(versions)))
        .order('id DESC')
        .first
        .try { |result| QaSubmission.new(result.attributes) }
    end

    def prepared_versions(versions)
      versions.sort
    end

    def table
      store.arel_table
    end
  end
end
