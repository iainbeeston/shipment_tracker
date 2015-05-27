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
      GitCommit.new(id: 'abc1238'),
      GitCommit.new(id: 'ghi9876'),
    ]
  }

  let(:events) {
    [
      build(:jira_event,
        comment_body: "please review\n#{feature_review_url(foo: 'abc1238')}",
           ),
      build(:jira_event,
        comment_body: "please review\n#{ feature_review_url(foo: 'abc1238', zar: '123asdf') }",
           ),
      build(:jira_event,
        comment_body: "please review\n#{feature_review_url(foo: 'sss1238')}",
           ),
      build(:jira_event, :done),
    ]
  }

  before do
    allow(repository).to receive(:recent_commits).with(50).and_return(commits)
  end

  describe '#releases' do
    it 'returns the list of releases' do
      projection.apply_all(events)

      expect(projection.releases).to eq(
        [
          Release.new(
            commit: GitCommit.new(id: 'abc1238'),
            feature_review_path: feature_review_path(foo: 'abc1238', zar: '123asdf'),
          ),
          Release.new(
            commit: GitCommit.new(id: 'ghi9876'),
            feature_review_path: nil,
          ),
        ],
      )
    end
  end

  private

  def feature_review_path(app_commit)
    "/feature_reviews?#{{ apps: app_commit }.to_query}"
  end

  def feature_review_url(app_commit)
    "http://shipment-tracker.url#{feature_review_path(app_commit)}"
  end
end
