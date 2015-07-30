require 'rails_helper'

RSpec.describe Projections::BuildsProjection do
  let(:apps) { { 'frontend' => 'abc' } }

  subject(:projection) { Projections::BuildsProjection.new(apps: apps) }

  it 'projects last build' do
    projection.apply(build(:jenkins_event, success?: false, version: 'abc'))
    expect(projection.builds).to eq(
      'frontend' => Build.new(source: 'Jenkins', success: false, version: 'abc'),
    )

    projection.apply(build(:jenkins_event, success?: true, version: 'abc'))
    expect(projection.builds).to eq(
      'frontend' => Build.new(source: 'Jenkins', success: true, version: 'abc'),
    )
  end

  context 'with multiple apps' do
    let(:apps) { { 'frontend' => 'abc', 'backend' => 'def', 'other' => 'xyz' } }

    it 'returns multiple builds' do
      projection.apply(build(:jenkins_event, success?: false, version: 'abc'))
      projection.apply(build(:circle_ci_event, success?: true, version: 'def'))

      expect(projection.builds).to eq(
        'frontend' => Build.new(source: 'Jenkins', success: false, version: 'abc'),
        'backend'  => Build.new(source: 'CircleCi', success: true, version: 'def'),
        'other'    => Build.new,
      )
    end
  end
end
