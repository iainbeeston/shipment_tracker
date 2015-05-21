require 'rails_helper'
require 'feature_review_projection'

RSpec.describe FeatureReviewProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:uat_url) { 'http://uat.fundingcircle.com' }

  subject(:projection) { FeatureReviewProjection.new(apps: apps, uat_url: uat_url) }

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
