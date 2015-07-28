require 'rails_helper'
require 'support/shared_examples/locking_projection_examples'

RSpec.describe Projections::LockingDeploysProjection do
  let(:apps) { { 'frontend' => 'abc' } }
  let(:server) { 'uat.fundingcircle.com' }
  let(:projection_url) { feature_review_url(apps, server) }
  let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

  let(:defaults) { { app_name: 'frontend', server: server, deployed_by: 'Bob', version: 'abc' } }

  subject(:projection) {
    Projections::LockingDeploysProjection.new(feature_review_location)
  }

  it_behaves_like 'a locking projection' do
    context 'when no locking occurs' do
      it 'projects last deploy' do
        projection.apply(build(:deploy_event, defaults.merge(version: 'abc')))
        expect(projection.deploys).to eq([Deploy.new(defaults.merge(version: 'abc', correct: true))])

        projection.apply(build(:deploy_event, defaults.merge(version: 'def')))
        expect(projection.deploys).to eq([Deploy.new(defaults.merge(version: 'def', correct: false))])
      end
    end

    context 'when it becomes locked' do
      it 'projects the last deploy before it became locked' do
        expected_deploys = [Deploy.new(defaults.merge(version: 'abc', correct: true))]

        projection.apply(build(:deploy_event, defaults.merge(version: 'abc')))
        expect(projection.deploys).to eq(expected_deploys)

        projection.apply(lock_event)
        expect(projection.deploys).to eq(expected_deploys)

        projection.apply(build(:deploy_event, defaults.merge(version: 'xxx')))
        expect(projection.deploys).to eq(expected_deploys)
      end
    end

    context 'when it becomes unlocked' do
      it 'projects the last deploy' do
        projection.apply(build(:deploy_event, defaults.merge(version: 'abc')))
        projection.apply(lock_event)
        projection.apply(build(:deploy_event, defaults.merge(version: 'xxx')))
        projection.apply(unlock_event)

        expect(projection.deploys).to eq([Deploy.new(defaults.merge(version: 'xxx', correct: false))])
      end
    end
  end

  context 'with multiple apps' do
    let(:apps) { { 'frontend' => 'abc', 'backend' => 'abc' } }

    it 'returns multiple deploys' do
      projection.apply(build(:deploy_event, defaults.merge(app_name: 'frontend')))
      projection.apply(build(:deploy_event, defaults.merge(app_name: 'backend')))

      expect(projection.deploys).to eq([
        Deploy.new(defaults.merge(app_name: 'frontend', correct: true)),
        Deploy.new(defaults.merge(app_name: 'backend', correct: true)),
      ])
    end
  end

  it 'is case insensitive when a repo name and the event app name do not match in case' do
    projection.apply(build(:deploy_event, defaults.merge(app_name: 'Frontend')))

    expect(projection.deploys).to eq([
      Deploy.new(defaults.merge(app_name: 'frontend', correct: true)),
    ])
  end

  it 'ignores the deploys event when it is for another server' do
    projection.apply(build(:deploy_event, defaults.merge(server: 'other.fundingcircle.com')))

    expect(projection.deploys).to eq([])
  end

  it 'ignores the deploy event when it is for an app that is not under review' do
    projection.apply(build(:deploy_event, defaults.merge(app_name: 'irrelevant_app')))

    expect(projection.deploys).to eq([])
  end

  it 'reports an incorrect version deployed to the UAT when event is for a different app version' do
    projection.apply(build(:deploy_event, defaults))
    expect(projection.deploys.map(&:correct)).to eq([true])

    projection.apply(build(:deploy_event, defaults.merge(version: 'def')))
    expect(projection.deploys.map(&:correct)).to eq([false])
  end
end
