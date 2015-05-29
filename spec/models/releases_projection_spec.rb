require 'rails_helper'

RSpec.describe ReleasesProjection do
  subject(:projection) {
    ReleasesProjection.new(
      per_page: 50,
      git_repository: repository,
    )
  }

  let(:repository) { instance_double(GitRepository) }

  let(:commits) {
    [
      GitCommit.new(id: 'abc'),
      GitCommit.new(id: 'def'),
      GitCommit.new(id: 'ghi'),
    ]
  }

  let(:events) {
    [
      build(:jira_event, comment_body: feature_review_comment(foo: 'abc')),
      build(:jira_event, issue_id: 123, comment_body: feature_review_comment(foo: 'abc', bar: 'jkl')),
      build(:jira_event, comment_body: feature_review_comment(foo: 'xyz')),
      build(:jira_event, :done, issue_id: 123),
    ]
  }

  before do
    allow(repository).to receive(:recent_commits).with(50).and_return(commits)
    allow(repository).to receive(:get_dependent_commits).with('abc').and_return([GitCommit.new(id: 'def')])
  end

  describe '#releases' do
    it 'returns the list of releases' do
      projection.apply_all(events)

      expect(projection.releases).to eq(
        [
          Release.new(
            commit: GitCommit.new(id: 'abc'),
            feature_review_status: 'Done',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
          ),
          Release.new(
            commit: GitCommit.new(id: 'def'),
            feature_review_status: 'Done',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
          ),
          Release.new(
            commit: GitCommit.new(id: 'ghi'),
            feature_review_path: nil,
          ),
        ],
      )
    end
  end

  private

  def feature_review_comment(apps)
    "please review\n#{feature_review_url(apps)}"
  end

  def feature_review_path(apps)
    "/feature_reviews?#{{ apps: apps }.to_query}"
  end

  def feature_review_url(apps)
    "http://shipment-tracker.url#{feature_review_path(apps)}"
  end
end
