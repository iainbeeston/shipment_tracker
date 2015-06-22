require 'rails_helper'
require 'feature_review_lookup'
require 'git_repository'
require 'support/git_test_repository'

RSpec.describe FeatureReviewLookup do
  describe '#feature_requests_for' do
    let(:test_git_repo) { Support::GitTestRepository.new }
    let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
    let(:git_repository) { GitRepository.new(rugged_repo) }

    subject(:lookup) { FeatureReviewLookup.new(git_repository) }

    context 'when a Feature Review is linked to multiple times' do
      before do
        @commit = test_git_repo.create_commit(author_name: 'author')
        @url = "http://example.com/feature_reviews?apps[app1]=#{@commit.oid}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{@url}"))
        lookup.apply(build(:jira_event, comment_body: "Please review #{@url}"))
      end

      it 'returns a single URL to the Feature Review' do
        expect(lookup.feature_requests_for(@commit.oid)).to contain_exactly(@url)
      end
    end

    context 'when a Feature Review exists for a decendant (newer) commit in the branch' do
      before do
        test_git_repo.create_commit(author_name: 'Alice', message: 'master 1')
        test_git_repo.create_branch('branch')
        test_git_repo.checkout_branch('branch')
        test_git_repo.create_commit(author_name: 'Alice', message: 'branch 1')
        @commit1 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 2')
        @commit2 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 3')
        test_git_repo.checkout_branch('master')
        test_git_repo.merge_branch(branch_name: 'branch', author_name: 'Alice', time: Time.now)

        @url1 = "http://example.com/feature_reviews?apps[app1]=#{@commit1.oid}"
        @url2 = "http://example.com/feature_reviews?apps[app1]=#{@commit2.oid}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{@url1}"))
        lookup.apply(build(:jira_event, comment_body: "Review this instead: #{@url2}"))
      end

      it 'returns URLs for both exact match and Feature Review to the decendant sha' do
        expect(lookup.feature_requests_for(@commit1.oid)).to contain_exactly(@url1, @url2)
      end
    end

    context 'when a Feature Review exists for an ascendant (older) commit in the branch' do
      before do
        test_git_repo.create_commit(author_name: 'Alice', message: 'master 1')
        test_git_repo.create_branch('branch')
        test_git_repo.checkout_branch('branch')
        test_git_repo.create_commit(author_name: 'Alice', message: 'branch 1')
        @branch_2 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 2')
        @branch_3 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 3')
        test_git_repo.checkout_branch('master')
        test_git_repo.merge_branch(branch_name: 'branch', author_name: 'Alice', time: Time.now)

        @url = "http://example.com/feature_reviews?apps[app1]=#{@branch_2.oid}"

        lookup.apply(build(:jira_event, comment_body: "Here you go: #{@url}"))
      end

      it 'does not return any URLs' do
        expect(lookup.feature_requests_for(@branch_3.oid)).to be_empty
      end
    end

    context 'when searching for a non existent commit' do
      before do
        @commit_id = 'def'
        url = "http://example.com/feature_reviews?apps[app1]=#{@commit_id}"
        lookup.apply(build(:jira_event, comment_body: "Here you go: #{url}"))
      end

      it 'does not return a URL' do
        expect(lookup.feature_requests_for(@commit_id)).to be_empty
      end
    end

    context 'when given an irrelevant jira event' do
      before do
        lookup.apply(build(:jira_event, comment_body: nil))
      end

      it 'does not return a URL' do
        expect(lookup.feature_requests_for('random_string')).to be_empty
      end
    end

    context 'when given non jira events' do
      before do
        lookup.apply(build(:circle_ci_event))
      end

      it 'does not blow up' do
        expect { lookup.feature_requests_for('1') }.to_not raise_error
      end
    end
  end
end
