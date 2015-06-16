require 'rails_helper'

RSpec.describe BuildsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def', 'other' => 'xyz' } }
  let(:events) {
    [
      build(:jenkins_event, success?: false, version: 'abc'),
      build(:jenkins_event, success?: true, version: 'abc'), # Build retriggered.
      build(:circle_ci_event, success?: true, version: 'def'),
      build(:jenkins_event, success?: true, version: 'ghi'),
      build(:jira_event),
    ]
  }

  subject(:projection) { BuildsProjection.new(apps: apps) }

  it 'projects the last build' do
    events.each do |event|
      projection.apply(event)
    end

    expect(projection.builds).to eq(
      'frontend' => Build.new(source: 'Jenkins', status: 'success', version: 'abc'),
      'backend'  => Build.new(source: 'CircleCi', status: 'success', version: 'def'),
      'other'    => Build.new,
    )
  end
end
