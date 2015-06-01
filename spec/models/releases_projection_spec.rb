require 'rails_helper'

RSpec.describe ReleasesProjection do
  subject(:projection) {
    ReleasesProjection.new(
      per_page: 50,
      git_repository: repository,
    )
  }

  let(:repository) { instance_double(GitRepository) }

  let(:time) { Time.now }

  let(:commits) {
    [
      GitCommit.new(id: 'abc', message: 'abc done', time: time),
      GitCommit.new(id: 'def', message: 'def done', time: time),
      GitCommit.new(id: 'ghi', message: 'ghi done', time: time),
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
            version: 'abc',
            subject: 'abc done',
            time: time,
            feature_review_status: 'Done',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
          ),
          Release.new(
            version: 'def',
            subject: 'def done',
            time: time,
            feature_review_status: 'Done',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
          ),
          Release.new(
            version: 'ghi',
            subject: 'ghi done',
            time: time,
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
