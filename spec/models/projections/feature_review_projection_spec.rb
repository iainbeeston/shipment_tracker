require 'rails_helper'

RSpec.describe Projections::FeatureReviewProjection do
  let(:builds_projection) {
    instance_double(Projections::LockingBuildsProjection, builds: double(:builds))
  }

  let(:deploys_projection) {
    instance_double(Projections::LockingDeploysProjection, deploys: double(:deploys))
  }

  let(:manual_tests_projection) {
    instance_double(Projections::LockingManualTestsProjection, qa_submission: double(:qa_submission))
  }

  let(:tickets_projection) {
    instance_double(Projections::LockingTicketsProjection, tickets: double(:tickets))
  }

  let(:uatests_projection) {
    instance_double(Projections::LockingUatestsProjection, uatest: double(:uatest))
  }

  let(:uat_url) { 'http://uat.example.com' }
  let(:apps) { { 'a' => 'xxx' } }

  subject(:projection) {
    Projections::FeatureReviewProjection.new(
      uat_url: uat_url,
      apps: apps,
      builds_projection: builds_projection,
      deploys_projection: deploys_projection,
      manual_tests_projection: manual_tests_projection,
      tickets_projection: tickets_projection,
      uatests_projection: uatests_projection,
    )
  }

  let(:event) { build(:jira_event) }

  it 'applies events to its subprojections' do
    expect(builds_projection).to receive(:apply).with(event)
    expect(deploys_projection).to receive(:apply).with(event)
    expect(manual_tests_projection).to receive(:apply).with(event)
    expect(tickets_projection).to receive(:apply).with(event)
    expect(uatests_projection).to receive(:apply).with(event)

    projection.apply(event)
  end

  describe '.build' do
    let(:projection_url) {
      "http://shipment-tracker.example.com/feature_reviews?apps[app1]=abc&uat_url=#{uat_url}"
    }

    let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

    it 'passes the correct values' do
      expect(Projections::LockingBuildsProjection).to receive(:new)
        .with(feature_review_location).and_return(builds_projection)
      expect(Projections::LockingDeploysProjection).to receive(:new)
        .with(feature_review_location).and_return(deploys_projection)
      expect(Projections::LockingManualTestsProjection).to receive(:new)
        .with(feature_review_location).and_return(manual_tests_projection)
      expect(Projections::LockingTicketsProjection).to receive(:new)
        .with(feature_review_location).and_return(tickets_projection)
      allow(Projections::LockingUatestsProjection).to receive(:new)
        .with(feature_review_location).and_return(uatests_projection)

      expect(Projections::FeatureReviewProjection).to receive(:new).with(
        uat_url: feature_review_location.uat_url,
        apps: feature_review_location.app_versions,
        builds_projection: builds_projection,
        deploys_projection: deploys_projection,
        manual_tests_projection: manual_tests_projection,
        tickets_projection: tickets_projection,
        uatests_projection: uatests_projection,
      )

      Projections::FeatureReviewProjection.build(projection_url)
    end
  end

  describe '#tickets' do
    it 'delegates to the tickets projection' do
      expect(projection.tickets).to eq(tickets_projection.tickets)
    end
  end

  describe '#deploys' do
    it 'delegates to the deploys projection' do
      expect(projection.deploys).to eq(deploys_projection.deploys)
    end
  end

  describe '#apps' do
    it 'returns the apps from the url' do
      expect(projection.apps).to eq(apps)
    end
  end

  describe '#builds' do
    it 'delegates to the builds projection' do
      expect(projection.builds).to eq(builds_projection.builds)
    end
  end

  describe '#qa_submission' do
    it 'delegates to the manual tests projection' do
      expect(projection.qa_submission).to eq(manual_tests_projection.qa_submission)
    end
  end

  describe '#uatest' do
    it 'delegates to the uatests projection' do
      expect(projection.uatest).to eq(uatests_projection.uatest)
    end
  end

  describe '#uat_url' do
    let(:uat_url) { 'https://uat.example.com' }
    it { expect(projection.uat_url).to eq('https://uat.example.com') }
  end
end
