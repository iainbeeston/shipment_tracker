require 'rails_helper'

RSpec.describe Projections::DeploysProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:server) { 'uat.fundingcircle.com' }
  let(:other_server) { 'other.fundingcircle.com' }
  let(:events) {
    [
      build(:deploy_event, app_name: 'frontend',
                           server: server,
                           version: 'old_version',
                           deployed_by: 'Alice'),
      build(:deploy_event, app_name: 'frontend',
                           server: server,
                           version: 'abc',
                           deployed_by: 'Bob'),
      build(:deploy_event, app_name: 'backend',
                           server: server,
                           version: 'wrong_version',
                           deployed_by: 'Carol'),
      build(:deploy_event, app_name: 'frontend',
                           server: other_server,
                           version: 'other_version',
                           deployed_by: 'Dave'),
      build(:deploy_event, app_name: 'irrelevant',
                           server: server,
                           version: 'any_version',
                           deployed_by: 'Eve'),
    ]
  }

  subject(:projection) { Projections::DeploysProjection.new(apps: apps, server: server) }

  it 'returns the apps versions deployed on the specified server' do
    events.each do |event|
      projection.apply(event)
    end

    expect(projection.deploys).to eq([
      Deploy.new(
        app_name: 'frontend',
        server: server,
        version: 'abc',
        deployed_by: 'Bob',
        correct: true,
      ),
      Deploy.new(
        app_name: 'backend',
        server: server,
        version: 'wrong_version',
        deployed_by: 'Carol',
        correct: false,
      ),
    ])
  end
end
