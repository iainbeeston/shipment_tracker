require 'rails_helper'

RSpec.describe Projections::FeatureReviewProjection do
  let(:builds_projection) { instance_double(Projections::BuildsProjection, builds: double(:builds)) }
  let(:deploys_projection) { instance_double(Projections::DeploysProjection, deploys: double(:deploys)) }
  let(:tickets_projection) { instance_double(Projections::TicketsProjection, tickets: double(:tickets)) }
  let(:uatests_projection) { instance_double(Projections::UatestsProjection, uatest: double(:uatest)) }
  let(:manual_tests_projection) {
    instance_double(Projections::ManualTestsProjection, qa_submission: double(:qa_submission))
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

  describe '.load' do
    let(:uat_host) { 'foo.com' }
    let(:uat_url) { "http://#{uat_host}" }

    let(:projection_url) { feature_review_url(apps, uat_url) }
    let(:expected_projection) { instance_double(Projections::FeatureReviewProjection) }
    let(:events) { [Event.new] }

    before do
      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'passes the correct values and feeds events' do
      expect(Projections::BuildsProjection).to receive(:new)
        .with(apps: apps).and_return(builds_projection)
      expect(Projections::DeploysProjection).to receive(:new)
        .with(apps: apps, server: uat_host).and_return(deploys_projection)
      expect(Projections::ManualTestsProjection).to receive(:new)
        .with(apps: apps).and_return(manual_tests_projection)
      expect(Projections::TicketsProjection).to receive(:new)
        .with(projection_url: projection_url).and_return(tickets_projection)
      allow(Projections::UatestsProjection).to receive(:new)
        .with(apps: apps, server: uat_host).and_return(uatests_projection)

      expect(Projections::FeatureReviewProjection).to receive(:new).with(
        uat_url: uat_url,
        apps: apps,
        builds_projection: builds_projection,
        deploys_projection: deploys_projection,
        manual_tests_projection: manual_tests_projection,
        tickets_projection: tickets_projection,
        uatests_projection: uatests_projection,
      ).and_return(expected_projection)

      expect(expected_projection).to receive(:apply_all).with(events)

      expect(Projections::FeatureReviewProjection.load(projection_url)).to eq(expected_projection)
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
