require 'rails_helper'
require 'support/git_test_repository'
require 'support/repository_builder'

require 'feature_review_search_projection'
require 'git_repository'

RSpec.describe FeatureReviewSearchProjection do
  describe '#feature_requests_for' do
    let(:git_diagram) { '-o' }
    let(:test_git_repo) { Support::RepositoryBuilder.build(git_diagram) }
    let(:another_test_git_repo) { Support::GitTestRepository.new }
    let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
    let(:another_rugged_repo) { Rugged::Repository.new(another_test_git_repo.dir) }
    let(:git_repository) { GitRepository.new(rugged_repo) }
    let(:another_git_repository) { GitRepository.new(another_rugged_repo) }

    subject(:lookup) {
      FeatureReviewSearchProjection.new(git_repositories: [another_git_repository, git_repository])
    }

    context 'when a Feature Review is linked to multiple times' do
      let(:git_diagram) { '-A' }

      it 'returns a single URL to the Feature Review' do
        url = "http://example.com/feature_reviews?apps[app1]=#{commit('A')}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{url}"))
        lookup.apply(build(:jira_event, comment_body: "Please review #{url}"))

        expect(lookup.feature_requests_for(commit('A'))).to contain_exactly(path_from_url(url))
      end
    end

    context 'when a Feature Review exists for a decendant (newer) commit in the branch' do
      let(:git_diagram) do
        <<-'EOS'
             o-A-B
            /     \
          -o-------o
        EOS
      end

      it 'returns URLs for both exact match and Feature Review to the decendant sha' do
        url1 = "http://example.com/feature_reviews?apps[app1]=#{commit('A')}"
        url2 = "http://example.com/feature_reviews?apps[app1]=#{commit('B')}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{url1}"))
        lookup.apply(build(:jira_event, comment_body: "Review this instead: #{url2}"))

        expect(lookup.feature_requests_for(commit('A'))).to contain_exactly(
          path_from_url(url1),
          path_from_url(url2),
        )
      end
    end

    context 'when a Feature Review exists for an ascendant (older) commit in the branch' do
      let(:git_diagram) do
        <<-'EOS'
             o-A-B
            /     \
          -o-------o
        EOS
      end

      it 'does not return any URLs' do
        url = "http://example.com/feature_reviews?apps[app1]=#{commit('A')}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{url}"))
        expect(lookup.feature_requests_for(commit('B'))).to be_empty
      end
    end

    context 'when searching for a non existent commit' do
      it 'does not return a URL' do
        commit_id = 'def'
        url = "http://example.com/feature_reviews?apps[app1]=#{commit_id}"
        lookup.apply(build(:jira_event, comment_body: "Here you go: #{url}"))
        expect(lookup.feature_requests_for(commit_id)).to be_empty
      end
    end

    context 'when given an irrelevant jira event' do
      it 'does not return a URL' do
        lookup.apply(build(:jira_event, comment_body: nil))
        expect(lookup.feature_requests_for('random_string')).to be_empty
      end
    end

    context 'when given non jira events' do
      it 'does not blow up' do
        lookup.apply(build(:circle_ci_event))
        expect { lookup.feature_requests_for('1') }.to_not raise_error
      end
    end
  end

  private

  def path_from_url(url)
    URI.parse(url).request_uri
  end

  def commit(version)
    test_git_repo.commit_for_pretend_version(version)
  end
end
