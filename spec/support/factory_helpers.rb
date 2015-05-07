module Support
  module FactoryHelpers
    def jira_events(end_status, opts)
      sequence = [:to_do, :in_progress, :ready_for_review, :done]
      sequence[0..sequence.index(end_status)].map do |status|
        FactoryGirl.build(:jira_event, status, opts)
      end
    end
  end
end
