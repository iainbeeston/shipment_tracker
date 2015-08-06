require 'rails_helper'
require 'repositories/feature_review_repository'

RSpec.describe Repositories::FeatureReviewRepository do
  subject(:repository) { Repositories::FeatureReviewRepository.new }

  describe '#table_name' do
    let(:active_record_class) { class_double(Snapshots::FeatureReview, table_name: 'the_table_name') }

    subject(:repository) { Repositories::FeatureReviewRepository.new(active_record_class) }

    it 'delegates to the active record class backing the repository' do
      expect(repository.table_name).to eq('the_table_name')
    end
  end

  describe '#feature_reviews_for' do
    it 'returns matching URLs' do
      [
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'abc', backend: 'NON1')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'def')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'NON3')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'ghi',  backend: 'NON3')} "\
                                         "and: #{feature_review_url(frontend: 'NON4', backend: 'NON5')}"),
      ].each do |event|
        repository.apply(event)
      end

      expect(repository.feature_reviews_for(%w(abc def ghi))).to match_array([
        feature_review_url(frontend: 'abc', backend: 'NON1'),
        feature_review_url(frontend: 'NON2', backend: 'def'),
        feature_review_url(frontend: 'ghi', backend: 'NON3'),
      ])
    end
  end
end
