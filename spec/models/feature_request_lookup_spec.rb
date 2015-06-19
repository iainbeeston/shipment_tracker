require 'rails_helper'
require 'feature_request_lookup'
require 'git_repository'
require 'support/git_test_repository'

RSpec.describe FeatureRequestLookup do
  describe '#feature_requests_for' do
    let(:test_git_repo) { Support::GitTestRepository.new }
    let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
    let(:git_repository) { GitRepository.new(rugged_repo) }

    subject(:lookup) { FeatureRequestLookup.new(git_repository) }

    context 'simple case' do
      before do
        @commit = test_git_repo.create_commit(
          author_name: 'author',
          pretend_version: 'abc',
        )

        @url = "http://example.com/feature_reviews?apps[app1]=#{@commit.oid}"

        lookup.apply(
          build(:jira_event, comment_body: "Here you go: #{@url}"),
        )
      end

      it 'returns an array' do
        feature_request_urls = lookup.feature_requests_for(@commit.oid)

        expect(feature_request_urls).to eq([@url])
      end
    end

    context 'when asked to search for a non existent commit' do
      before do
        @commit_id = 'def'
        url = "http://example.com/feature_reviews?apps[app1]=#{@commit_id}"
        lookup.apply(
          build(:jira_event, comment_body: "Here you go: #{url}"),
        )
      end

      it 'ignores it' do
        feature_request_urls = lookup.feature_requests_for(@commit_id)

        expect(feature_request_urls).to eq([])
      end
    end

    context 'when given an irrelevant jira event' do
      before do
        url = 'http://example.com/feature_reviews?apps[app1]=foobarbaz'
        lookup.apply(
          build(:jira_event, comment_body: "Here you go: #{url}"),
        )
      end

      it 'ignores it' do
        feature_request_urls = lookup.feature_requests_for('someothercommit')

        expect(feature_request_urls).to eq([])
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
