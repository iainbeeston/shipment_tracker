require 'rails_helper'
require 'repositories/feature_review_repository'

RSpec.describe Repositories::FeatureReviewRepository do
  subject(:repository) { Repositories::FeatureReviewRepository.new }

  describe '#feature_reviews_for' do
    let(:events) {
      [
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'abc', backend: 'NON1')}"),
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'NON2', backend: 'def')}"),
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'NON2', backend: 'NON3')}"),
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'ghi',  backend: 'NON3')} "\
                                         "and: #{url_for(frontend: 'NON4', backend: 'NON5')}"),
      ]
    }

    before do
      repository.apply_all(events)
    end

    it 'returns the URLs of feature reviews that include at least one of the provided versions' do
      expect(repository.feature_reviews_for(%w(abc def ghi))).to contain_exactly(
        url_for(frontend: 'abc', backend: 'NON1'),
        url_for(frontend: 'NON2', backend: 'def'),
        url_for(frontend: 'ghi', backend: 'NON3'),
      )
    end

    it 'returns a set' do
      expect(repository.feature_reviews_for(%w(abc def ghi))).to be_a(Set)
    end
  end

  describe '#last_id' do
    it 'can retrieve the last event id seen' do
      expect(repository.last_id).to eq(0)

      repository.apply_all([
        build(:jira_event, id: 1),
        build(:jira_event, id: 22),
      ])

      expect(repository.last_id).to eq(22)

      repository.apply_all([
        build(:jira_event, id: 34),
        build(:circle_ci_event, id: 46),
      ])

      expect(repository.last_id).to eq(46)
    end
  end
end
