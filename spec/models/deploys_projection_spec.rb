require 'rails_helper'

RSpec.describe DeploysProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:uat_url) { 'http://uat.fundingcircle.com' }
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

  subject(:projection) { DeploysProjection.new(apps: apps, uat_url: uat_url) }

  it 'returns the apps versions deployed on the specified server' do
    events.each do |event|
      projection.apply(event)
    end

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
