require 'forwardable'

module Projections
  class ManualTestsProjection
    attr_reader :qa_submission

    def initialize(apps:, qa_submission: nil)
      @apps = apps
      @qa_submission = qa_submission
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

    def clone
      self.class.new(apps: @apps.clone, qa_submission: @qa_submission.try(:clone))
    end

    private

    def apps_hash(apps_list)
      apps_list.map { |app| app.values_at('name', 'version') }.to_h
    end
  end

  class LockingManualTestsProjection
    extend Forwardable

    def initialize(feature_review_location)
      @projection = LockingProjectionWrapper.new(
        ManualTestsProjection.new(apps: feature_review_location.app_versions),
        feature_review_location.url,
      )
    end

    def_delegators :@projection, :apply, :qa_submission
  end
end
