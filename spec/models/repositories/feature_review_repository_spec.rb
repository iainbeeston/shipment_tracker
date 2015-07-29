require 'rails_helper'
require 'repositories/feature_review_repository'

RSpec.describe Repositories::FeatureReviewRepository do
  subject(:repository) { Repositories::FeatureReviewRepository.new }

  describe '#update' do
    it 'updates the #new_events' do
      event_1 = create(:jira_event)
      event_2 = create(:circle_ci_event)
      event_3 = create(:jira_event)
      event_4 = create(:jira_event)

      expect(repository.new_events.to_a).to eq([event_1, event_2, event_3, event_4])

      repository.update

      expect(repository.new_events.to_a).to be_empty

      event_5 = create(:jira_event)

      expect(repository.new_events.to_a).to eq([event_5])
    end

    it 'updates the #feature_reviews_for' do
      create(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'abc', backend: 'NON1')}")
      create(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'def')}")
      create(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'NON3')}")
      create(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'ghi',  backend: 'NON3')} "\
                                        "and: #{feature_review_url(frontend: 'NON4', backend: 'NON5')}")

      expect(repository.feature_reviews_for(%w(abc def ghi))).to eq(Set.new)

      repository.update

      expect(repository.feature_reviews_for(%w(abc def ghi))).to contain_exactly(
        feature_review_url(frontend: 'abc', backend: 'NON1'),
        feature_review_url(frontend: 'NON2', backend: 'def'),
        feature_review_url(frontend: 'ghi', backend: 'NON3'),
      )
    end
  end
end
