require 'rails_helper'
require 'support/repository_builder'
require 'rugged/repository'
require 'git_repository'

require 'transformer/pull_request'

RSpec.describe Transformer::PullRequest do
  let(:test_git_repo) { Support::RepositoryBuilder.build(git_diagram) }
  let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
  let(:git_repository) { GitRepository.new(rugged_repo) }

  subject(:transformer) { Transformer::PullRequest.new(git_repository) }

  describe '#feature_reviews_for(version)' do
    let(:url_a) { "http://example.com/feature_reviews?apps[app1]=#{commit('A')}" }
    let(:url_b) { "http://example.com/feature_reviews?apps[app1]=#{commit('B')}" }
    let(:url_c) { "http://example.com/feature_reviews?apps[app1]=#{commit('C')}" }
    let(:url_d) { "http://example.com/feature_reviews?apps[app1]=#{commit('D')}" }

    def test(commit_name, expected)
      actual = transformer.feature_reviews_for(commit(commit_name))
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
      transformer.apply_all feature_reviews_urls.map { |url|
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
  end

  private

  def commit(commit_name)
    test_git_repo.commit_for_pretend_version(commit_name)
  end
end
