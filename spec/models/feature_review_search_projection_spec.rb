require 'rails_helper'
require 'support/git_test_repository'
require 'support/repository_builder'

require 'feature_review_search_projection'
require 'git_repository'

RSpec.describe FeatureReviewSearchProjection do
  let(:test_git_repo) { Support::RepositoryBuilder.build(git_diagram) }
  let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
  let(:git_repository) { GitRepository.new(rugged_repo) }

  subject(:projection) { FeatureReviewSearchProjection.new(git_repository) }

  describe '#feature_reviews_for(version)' do
    let(:url_a) { Support::FeatureReviewUrl.build(app1: commit('A')) }
    let(:url_b) { Support::FeatureReviewUrl.build(app1: commit('B')) }
    let(:url_c) { Support::FeatureReviewUrl.build(app1: commit('C')) }
    let(:url_d) { Support::FeatureReviewUrl.build(app1: commit('D')) }

    let(:feature_reviews_urls) { [] }

    def test(commit_name, expected)
      actual = projection.feature_reviews_for(commit(commit_name))
      expect(actual).to(
        match_array(expected),
        <<-EOS
With commits:
  A = #{commit('A')}
  B = #{commit('B')}
  C = #{commit('C')}
  D = #{commit('D')}

And feature_review_urls:
  #{feature_reviews_urls.join("\n  ")}

In tree:

  #{git_diagram.strip_heredoc.gsub("\n", "\n  ")}
Expected #{commit_name} to return:
  #{expected.join("\n  ")},

Actually got:
  #{actual.join("\n  ")}
EOS
      )
    end

    let(:git_diagram) do
      <<-'EOS'
           A-B
          /   \
        -o-----C---D
      EOS
    end

    before do
      projection.apply_all feature_reviews_urls.map { |url|
        build(:jira_event, comment_body: "Here you go: #{url}")
      }
    end

    context 'when a feature review exists for A' do
      let(:feature_reviews_urls) { [url_a] }

      it do
        aggregate_failures 'testing each permutation' do
          {
            'A' => [url_a],
            'B' => [],
            'C' => [],
            'D' => [],
          }.each(&method(:test))
        end
      end
    end

    context 'when a feature review exists for B' do
      let(:feature_reviews_urls) { [url_b] }

      it do
        aggregate_failures 'testing each permutation' do
          {
            'A' => [url_b],
            'B' => [url_b],
            'C' => [url_b],
            'D' => [],
          }.each(&method(:test))
        end
      end
    end

    context 'when a feature review exists for C' do
      let(:feature_reviews_urls) { [url_c] }

      it do
        aggregate_failures 'testing each permutation' do
          {
            'A' => [url_c],
            'B' => [url_c],
            'C' => [url_c],
            'D' => [],
          }.each(&method(:test))
        end
      end
    end

    context 'when a feature review exists for A, B and D' do
      let(:feature_reviews_urls) { [url_a, url_b, url_d] }

      it do
        aggregate_failures 'testing each permutation' do
          {
            'A' => [url_a, url_b],
            'B' => [url_b],
            'C' => [url_b],
            'D' => [url_d],
          }.each(&method(:test))
        end
      end
    end

    context 'when searching for a non existent commit' do
      let(:commit_id) { 'def' }
      let(:feature_reviews_urls) { [Support::FeatureReviewUrl.build(app1: commit_id)] }

      it 'does not return a URL' do
        expect(projection.feature_reviews_for(commit_id)).to be_empty
      end
    end

    context 'when given an irrelevant jira event' do
      it 'does not return a URL' do
        projection.apply_all([build(:jira_event, comment_body: nil)])
        expect(projection.feature_reviews_for('random_string')).to be_empty
      end
    end

    context 'when given non jira events' do
      it 'does not blow up' do
        projection.apply_all([build(:circle_ci_event)])
        expect { projection.feature_reviews_for('1') }.to_not raise_error
      end
    end
  end

  private

  def commit(version)
    test_git_repo.commit_for_pretend_version(version)
  end
end
