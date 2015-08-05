require 'rails_helper'

RSpec.describe Projections::BuildsProjection do
  let(:apps) { { 'frontend' => 'abc' } }

  subject(:projection) { Projections::BuildsProjection.new(apps: apps) }

  describe '.load' do
    let(:repository) { instance_double(Repositories::BuildRepository) }
    let(:expected_builds) { [Build.new] }
    let(:expected_events) { [Event.new] }
    let(:expected_projection) { instance_double(Projections::BuildsProjection) }
    let(:time) { Time.current }

    it 'inflates the projection and feeds it remaining events' do
      allow(repository).to receive(:builds_for)
        .with(apps: apps, at: time)
        .and_return(builds: expected_builds, events: expected_events)

      allow(Projections::BuildsProjection).to receive(:new).with(
        apps: apps,
        builds: expected_builds,
      ).and_return(expected_projection)

      expect(expected_projection).to receive(:apply_all).with(expected_events)

      expect(
        Projections::BuildsProjection.load(apps: apps, at: time, repository: repository),
      ).to be(expected_projection)
    end
  end

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
