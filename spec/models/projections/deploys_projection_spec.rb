require 'rails_helper'

RSpec.describe Projections::DeploysProjection do
  let(:apps) { { 'frontend' => 'abc' } }
  let(:server) { 'uat.fundingcircle.com' }

  let(:defaults) { { app_name: 'frontend', server: server, deployed_by: 'Bob', version: 'abc' } }

  subject(:projection) {
    Projections::DeploysProjection.new(apps: apps, server: server)
  }

  it 'projects last deploy' do
    projection.apply(build(:deploy_event, defaults.merge(version: 'abc')))
    expect(projection.deploys).to eq([Deploy.new(defaults.merge(version: 'abc', correct: true))])

    projection.apply(build(:deploy_event, defaults.merge(version: 'def')))
    expect(projection.deploys).to eq([Deploy.new(defaults.merge(version: 'def', correct: false))])
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
