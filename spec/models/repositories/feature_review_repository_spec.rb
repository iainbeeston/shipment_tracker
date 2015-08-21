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

  describe '#apply' do
    let(:active_record_class) { class_double(Snapshots::FeatureReview) }

    subject(:repository) { Repositories::FeatureReviewRepository.new(active_record_class) }

    it 'creates a snapshot for each feature review url in the event comment' do
      expect(active_record_class).to receive(:create!).with(url: feature_review_url(frontend: 'abc', backend: 'NON1'), versions: ['NON1', 'abc'])
      expect(active_record_class).to receive(:create!).with(url: feature_review_url(frontend: 'NON2', backend: 'def'), versions: ['def', 'NON2'])
      expect(active_record_class).to receive(:create!).with(url: feature_review_url(frontend: 'NON2', backend: 'NON3'), versions: ['NON3', 'NON2'])
      expect(active_record_class).to receive(:create!).with(url: feature_review_url(frontend: 'ghi',  backend: 'NON3'), versions: ['NON3', 'ghi'])
      expect(active_record_class).to receive(:create!).with(url: feature_review_url(frontend: 'NON4', backend: 'NON5'), versions: ['NON5', 'NON4'])

      [
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'abc', backend: 'NON1')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'def')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'NON2', backend: 'NON3')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'ghi',  backend: 'NON3')} "\
                                         "and: #{feature_review_url(frontend: 'NON4', backend: 'NON5')}"),
      ].each do |event|
        repository.apply(event)
      end
    end
  end

  describe '#feature_reviews_for' do
    it 'returns the latest snapshots for the versions specified' do
      Snapshots::FeatureReview.create!(url: feature_review_url(frontend: 'abc', backend: 'NON1'), versions: ['NON1', 'abc'])
      Snapshots::FeatureReview.create!(url: feature_review_url(frontend: 'NON2', backend: 'def'), versions: ['def', 'NON2'])
      Snapshots::FeatureReview.create!(url: feature_review_url(frontend: 'NON2', backend: 'NON3'), versions: ['NON3', 'NON2'])
      Snapshots::FeatureReview.create!(url: feature_review_url(frontend: 'ghi',  backend: 'NON3'), versions: ['NON3', 'ghi'])
      Snapshots::FeatureReview.create!(url: feature_review_url(frontend: 'NON4', backend: 'NON5'), versions: ['NON5', 'NON4'])

      expect(repository.feature_reviews_for(%w(abc def ghi))).to match_array([
        feature_review_url(frontend: 'abc', backend: 'NON1'),
        feature_review_url(frontend: 'NON2', backend: 'def'),
        feature_review_url(frontend: 'ghi', backend: 'NON3'),
      ])
    end
  end
end
