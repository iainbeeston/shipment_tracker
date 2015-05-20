require 'rails_helper'
require 'feature_review_projection'

RSpec.describe FeatureReviewProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:uat_url) { 'http://uat.fundingcircle.com' }
  let(:projection_url) { 'http://example.com/feature_reviews?foo[bar]=baz' }

  subject(:projection) {
    FeatureReviewProjection.new(
      apps: apps,
      uat_url: uat_url,
      projection_url: projection_url,
    )
  }

  describe 'tickets projection' do
    let(:jira_1) { { key: 'JIRA-1', summary: 'Ticket 1' } }
    let(:jira_4) { { key: 'JIRA-4', summary: 'Ticket 4' } }

    let(:events) {
      [
        build(:jira_event, :to_do, jira_1),
        build(:jira_event, :in_progress, jira_1),
        build(:jira_event, :ready_for_review, jira_1.merge(comment_body: "Please review #{projection_url}")),
        build(:jira_event, :done, jira_1),

        build(:jira_event, :to_do, key: 'JIRA-2'),
        build(:jira_event, :to_do, key: 'JIRA-3', comment_body: "Review #{projection_url}/extra/stuff"),

        build(:jira_event, :to_do, jira_4),
        build(:jira_event, :in_progress, jira_4),
        build(:jira_event, :ready_for_review, jira_4.merge(comment_body: "#{projection_url} is ready!")),
      ]
    }

    it 'projects the tickets referenced in JIRA comments' do
      projection.apply_all(events)

      expect(projection.tickets).to eq([
        Ticket.new(key: 'JIRA-1', summary: 'Ticket 1', status: 'Done'),
        Ticket.new(key: 'JIRA-4', summary: 'Ticket 4', status: 'Ready For Review'),
      ])
    end

    context 'when url is percent encoded' do
      let(:url) { 'http://example.com/feature_reviews?foo%5Bbar%5D=baz' }

      let(:events) { [build(:jira_event, key: 'JIRA-1', summary: '', comment_body: "Review #{url}")] }

      it 'projects the tickets referenced in JIRA comments' do
        projection.apply_all(events)

        expect(projection.tickets).to eq([
          Ticket.new(key: 'JIRA-1', summary: '', status: 'To Do'),
        ])
      end
    end
  end

  describe 'builds projection' do
    let(:events) {
      [
        build(:circle_ci_event, success?: false, version: 'abc'),
        build(:jenkins_event, success?: true, version: 'abc'), # Build retriggered.
        build(:circle_ci_event, success?: true, version: 'def'),
        build(:jenkins_event, success?: true, version: 'ghi'),
        build(:jira_event),
      ]
    }

    it 'projects the last build' do
      projection.apply_all(events)

      expect(projection.builds).to eq(
        'frontend' => [
          Build.new(source: 'CircleCi', status: 'failed', version: 'abc'),
          Build.new(source: 'Jenkins', status: 'success', version: 'abc'),
        ],
        'backend'  => [
          Build.new(source: 'CircleCi', status: 'success', version: 'def'),
        ],
      )
    end
  end

  describe 'deploys projection' do
    let(:other_uat_url) { 'http://other.fundingcircle.com' }
    let(:events) {
      [
        build(:deploy_event, app_name: 'frontend',
                             server: uat_url,
                             version: 'old_version',
                             deployed_by: 'Alice'),
        build(:deploy_event, app_name: 'frontend',
                             server: uat_url,
                             version: 'abc',
                             deployed_by: 'Bob'),
        build(:deploy_event, app_name: 'backend',
                             server: uat_url,
                             version: 'wrong_version',
                             deployed_by: 'Carol'),
        build(:deploy_event, app_name: 'frontend',
                             server: other_uat_url,
                             version: 'other_version',
                             deployed_by: 'Dave'),
        build(:deploy_event, app_name: 'irrelevant',
                             server: uat_url,
                             version: 'any_version',
                             deployed_by: 'Eve'),
      ]
    }

    it 'returns the apps versions deployed on the specified server' do
      projection.apply_all(events)

      expect(projection.deploys).to eq([
        Deploy.new(
          app_name: 'frontend',
          server: uat_url,
          version: 'abc',
          deployed_by: 'Bob',
          correct: :yes,
        ),
        Deploy.new(
          app_name: 'backend',
          server: uat_url,
          version: 'wrong_version',
          deployed_by: 'Carol',
          correct: :no,
        ),
        Deploy.new(
          app_name: 'irrelevant',
          server: uat_url,
          version: 'any_version',
          deployed_by: 'Eve',
          correct: :ignore,
        ),
      ])
    end
  end
end
