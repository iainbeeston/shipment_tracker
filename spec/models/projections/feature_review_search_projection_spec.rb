require 'rails_helper'
require 'support/git_test_repository'
require 'support/repository_builder'

require 'projections/feature_review_search_projection'
require 'git_repository'

RSpec.describe Projections::FeatureReviewSearchProjection do
  let(:test_git_repo) { Support::RepositoryBuilder.build(git_diagram) }
  let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
  let(:git_repository) { GitRepository.new(rugged_repo) }

  describe '#feature_reviews_for(version)' do
    let(:url_a) { Support::FeatureReviewUrl.build(app1: commit('A')) }
    let(:url_b) { Support::FeatureReviewUrl.build(app1: commit('B')) }
    let(:url_c) { Support::FeatureReviewUrl.build(app1: commit('C')) }
    let(:url_d) { Support::FeatureReviewUrl.build(app1: commit('D')) }

    let(:git_diagram) do
      <<-'EOS'
           A-B
          /   \
        -o-----C---D
      EOS
    end

    let(:events) { feature_reviews_urls.map { |url| build(:jira_event, comment_body: "Check: #{url}") } }

    def projection_for(version)
      Projections::FeatureReviewSearchProjection.new(
        git_repository: git_repository,
        version: commit(version),
      ).tap do |projection|
        projection.apply_all(events)
      end
    end

    context 'when a feature review exists for A' do
      let(:feature_reviews_urls) { [url_a] }

      it 'assigns that feature review to A only' do
        aggregate_failures do
          {
            'A' => [url_a],
            'B' => [],
            'C' => [],
            'D' => [],
          }.each do |commit_name, expected_urls|
            expect(projection_for(commit_name).feature_reviews).to match_array(expected_urls)
          end
        end
      end
    end

    context 'when a feature review exists for B' do
      let(:feature_reviews_urls) { [url_b] }

      it 'assigns that feature review to A, B & C' do
        aggregate_failures do
          {
            'A' => [url_b],
            'B' => [url_b],
            'C' => [url_b],
            'D' => [],
          }.each do |commit_name, expected_urls|
            expect(projection_for(commit_name).feature_reviews).to match_array(expected_urls)
          end
        end
      end
    end

    context 'when a feature review exists for C' do
      let(:feature_reviews_urls) { [url_c] }

      it 'assigns that feature review to A, B & C' do
        aggregate_failures do
          {
            'A' => [url_c],
            'B' => [url_c],
            'C' => [url_c],
            'D' => [],
          }.each do |commit_name, expected_urls|
            expect(projection_for(commit_name).feature_reviews).to match_array(expected_urls)
          end
        end
      end
    end

    context 'when a feature review exists for A, B and D' do
      let(:feature_reviews_urls) { [url_a, url_b, url_d] }

      it 'assigns that feature reviews correctly' do
        aggregate_failures do
          {
            'A' => [url_a, url_b],
            'B' => [url_b],
            'C' => [url_b],
            'D' => [url_d],
          }.each do |commit_name, expected_urls|
            expect(projection_for(commit_name).feature_reviews).to match_array(expected_urls)
          end
        end
      end
    end

    context 'when searching for a non existent commit' do
      let(:version) { 'foo' }
      let(:feature_reviews_url) { Support::FeatureReviewUrl.build(app1: version) }

      subject(:projection) do
        Projections::FeatureReviewSearchProjection.new(
          git_repository: git_repository,
          version: version,
        )
      end

      it 'does not return a URL' do
        projection.apply_all([build(:jira_event, comment_body: feature_reviews_url)])
        expect(projection.feature_reviews).to be_empty
      end
    end

    context 'when given non jira events' do
      subject(:projection) do
        Projections::FeatureReviewSearchProjection.new(
          git_repository: git_repository,
          version: 'foo',
        )
      end

      it 'does not blow up' do
        projection.apply_all([build(:circle_ci_event)])
        expect { projection.feature_reviews }.to_not raise_error
      end
    end
  end

  private

  def commit(version)
    test_git_repo.commit_for_pretend_version(version)
  end
end
