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
    let(:jira_1) { { key: 'JIRA-1', summary: 'Ticket 1', description: 'Desc 1' } }
    let(:jira_4) { { key: 'JIRA-4', summary: 'Ticket 4', description: 'Desc 4' } }

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
        Ticket.new(key: 'JIRA-1', summary: 'Ticket 1', description: 'Desc 1', status: 'Done'),
        Ticket.new(key: 'JIRA-4', summary: 'Ticket 4', description: 'Desc 4', status: 'Ready For Review'),
      ])
    end

    context 'when multiple feature reviews are referenced in the same JIRA ticket' do
      let(:events) {
        [
          build(:jira_event, key: 'JIRA-1', comment_body: "Review #{url1}"),
          build(:jira_event, key: 'JIRA-1', comment_body: "Review again #{url2}"),
        ]
      }
      let(:url1) { 'http://example.com/feature_reviews?foo[bar]=one' }
      let(:url2) { 'http://example.com/feature_reviews?foo[bar]=two' }

      subject(:projection1) {
        FeatureReviewProjection.new(
          apps: apps,
          uat_url: uat_url,
          projection_url: url1,
        )
      }
      subject(:projection2) {
        FeatureReviewProjection.new(
          apps: apps.merge('backend' => 'ghi', 'extra_app' => 'jkl'),
          uat_url: uat_url,
          projection_url: url2,
        )
      }

      it 'projects the ticket referenced in the JIRA comments for each projection ' do
        projection1.apply_all(events)
        projection2.apply_all(events)

        expect(projection1.tickets).to eq([Ticket.new(key: 'JIRA-1')])
        expect(projection2.tickets).to eq([Ticket.new(key: 'JIRA-1')])
      end
    end

    context 'when url is percent encoded' do
      let(:url) { 'http://example.com/feature_reviews?foo%5Bbar%5D=baz' }
      let(:events) { [build(:jira_event, key: 'JIRA-1', comment_body: "Review #{url}")] }

      it 'projects the tickets referenced in JIRA comments' do
        projection.apply_all(events)

        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-1', status: 'To Do')])
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
      ])
    end
  end

  describe 'QA submissions projection' do
    context 'test status is failure' do
      let(:events) {
        [
          build(:manual_test_event,
            status: 'success',
            name: 'Alice',
            apps: [
              { name: 'frontend', version: 'abc' },
              { name: 'backend', version: 'def' },
            ]),
          build(:manual_test_event,
            status: 'failed',
            name: 'Benjamin',
            apps: [
              { name: 'frontend', version: 'abc' },
              { name: 'backend', version: 'def' },
            ]),
          build(:manual_test_event,
            status: 'failed',
            name: 'Carol',
            apps: [
              { name: 'frontend', version: 'abc' },
              { name: 'backend', version: 'ghi' },
            ]),
        ]
      }

      it 'returns the last QA submission for the specified apps' do
        projection.apply_all(events)

        expect(projection.qa_submission).to eq(
          QaSubmission.new(
            status: 'rejected',
            name: 'Benjamin',
          ),
        )
      end
    end

    context 'test status is success' do
      let(:events) {
        [
          build(:manual_test_event,
            status: 'success',
            name: 'Alice',
            apps: [
              { name: 'frontend', version: 'abc' },
              { name: 'backend', version: 'def' },
            ]),
        ]
      }

      it 'returns the last QA submission for the specified apps' do
        projection.apply_all(events)

        expect(projection.qa_submission).to eq(
          QaSubmission.new(
            status: 'accepted',
            name: 'Alice',
          ),
        )
      end
    end
  end
end
