require 'rails_helper'
require 'support/shared_examples/locking_projection_examples'

RSpec.describe Projections::LockingBuildsProjection do
  let(:projection_url) { feature_review_url(apps) }
  let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

  subject(:projection) { Projections::LockingBuildsProjection.new(feature_review_location) }

  it_behaves_like 'a locking projection' do
    let(:apps) { { 'frontend' => 'abc' } }

    context 'when no locking occurs' do
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
    end

    context 'when it becomes locked' do
      it 'projects the last build before it became locked' do
        expected_builds = { 'frontend' => Build.new(source: 'Jenkins', success: false, version: 'abc') }

        projection.apply(build(:jenkins_event, success?: false, version: 'abc'))
        expect(projection.builds).to eq(expected_builds)

        projection.apply(lock_event)
        expect(projection.builds).to eq(expected_builds)

        projection.apply(build(:jenkins_event, success?: true, version: 'abc'))
        expect(projection.builds).to eq(expected_builds)
      end
    end

    context 'when it becomes unlocked' do
      it 'projects the last build' do
        projection.apply(build(:jenkins_event, success?: false, version: 'abc'))
        projection.apply(lock_event)
        projection.apply(build(:jenkins_event, success?: true, version: 'abc'))
        projection.apply(unlock_event)

        expect(projection.builds).to eq(
          'frontend' => Build.new(source: 'Jenkins', success: true, version: 'abc'),
        )
      end
    end
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
