require 'forwardable'

module Projections
  class ManualTestsProjection
    def self.load(apps:, at: nil, repository: Repositories::ManualTestRepository.new)
      state = repository.qa_submission_for(apps: apps, at: at)
      new(
        apps: apps,
        qa_submission: state.fetch(:qa_submission),
      ).tap { |p| p.apply_all(state.fetch(:events)) }
    end

    attr_reader :qa_submission

    def initialize(apps:, qa_submission: nil)
      @apps = apps
      @qa_submission = qa_submission
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def apply(event)
      return unless event.is_a?(ManualTestEvent)
      return unless apps_hash(event.apps) == @apps

      @qa_submission = QaSubmission.new(
        email: event.email,
        accepted: event.accepted?,
        comment: event.comment,
        created_at: event.created_at,
      )
    end

    private

    def apps_hash(apps_list)
      apps_list.map { |app| app.values_at('name', 'version') }.to_h
    end
  end
end
