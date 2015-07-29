require 'rails_helper'

RSpec.describe Projections::ReleasesProjection do
  subject(:projection) {
    Projections::ReleasesProjection.new(
      per_page: 50,
      git_repository: repository,
    )
  }

  let(:repository) { instance_double(GitRepository) }

  let(:time) { Time.now }

  let(:commits) {
    [
      GitCommit.new(id: 'abc', message: "abc done\nbody", time: time),
      GitCommit.new(id: 'def', message: "def done\n\nbody", time: time),
      GitCommit.new(id: 'ghi', message: "ghi done\n\nbody", time: time),
    ]
  }

  let(:events) {
    [
      build(:jira_event, comment_body: feature_review_comment(foo: 'abc')),
      build(:jira_event, key: 'JIRA-123', comment_body: feature_review_comment(foo: 'abc', bar: 'jkl')),
      build(:jira_event, comment_body: feature_review_comment(foo: 'xyz')),
      build(:jira_event, :approved, key: 'JIRA-123'),
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
            feature_review_status: 'Ready for Deployment',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
            approved: true,
          ),
          Release.new(
            version: 'def',
            subject: 'def done',
            time: time,
            feature_review_status: 'Ready for Deployment',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
            approved: true,
          ),
          Release.new(
            version: 'ghi',
            subject: 'ghi done',
            time: time,
            feature_review_path: nil,
            approved: false,
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
    URI.parse(feature_review_url(apps)).request_uri
  end
end
