require 'rails_helper'
require 'projections/releases_projection'
require 'git_commit'

RSpec.describe Projections::ReleasesProjection do
  subject(:projection) {
    Projections::ReleasesProjection.new(
      per_page: 50,
      git_repository: repository,
      app_name: app_name,
    )
  }

  let(:repository) { instance_double(GitRepository) }
  let(:app_name) { 'foo' }
  let(:time) { Time.current }
  let(:formatted_time) { time.to_formatted_s(:long_ordinal) }

  let(:commits) {
    [
      GitCommit.new(id: 'abc', message: "commit on topic branch\n\nchild of def", time: time - 1.hour),
      GitCommit.new(id: 'def', message: "commit on topic branch\n\nchild of ghi", time: time - 2.hours),
      GitCommit.new(id: 'ghi', message: 'commit on master branch', time: time - 3.hours),
    ]
  }

  let(:events) {
    [
      build(:deploy_event, environment: 'uat', app_name: app_name, version: 'def'),
      build(:deploy_event, environment: 'uat', app_name: app_name, version: 'abc'),

      build(:jira_event, key: 'JIRA-1', comment_body: feature_review_comment(foo: 'abc')),
      build(:jira_event, key: 'JIRA-2', comment_body: feature_review_comment(foo: 'abc', bar: 'jkl')),
      build(:jira_event, key: 'JIRA-3', comment_body: feature_review_comment(foo: 'xyz')),
      build(:jira_event, :approved, key: 'JIRA-2'),

      build(:deploy_event, version: 'def', environment: 'production', app_name: app_name, created_at: time),
      build(:deploy_event, version: 'klm', environment: 'production', app_name: 'irrelevant_app'),
    ]
  }

  before do
    allow(repository).to receive(:recent_commits).with(50).and_return(commits)
    allow(repository).to receive(:get_dependent_commits).with('abc').and_return([GitCommit.new(id: 'def')])
  end

  describe '#pending_releases' do
    it 'returns the list of releases not yet deployed to production' do
      projection.apply_all(events)

      expect(projection.pending_releases).to eq(
        [
          Release.new(
            version: 'abc',
            subject: 'commit on topic branch',
            time: nil,
            feature_review_status: 'Ready for Deployment',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'), # Only shows last associated FR
            approved: true, # A release has max one FR, so approved even when FR for JIRA-1 is not approved
          ),
        ],
      )
    end
  end

  describe '#deployed_releases' do
    it 'returns the list of releases deployed to production' do
      projection.apply_all(events)

      expect(projection.deployed_releases).to eq(
        [
          Release.new(
            version: 'def',
            subject: 'commit on topic branch',
            time: formatted_time,
            feature_review_status: 'Ready for Deployment',
            feature_review_path: feature_review_path(foo: 'abc', bar: 'jkl'),
            approved: true,
          ),
          Release.new(
            version: 'ghi',
            subject: 'commit on master branch',
            time: nil,
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
