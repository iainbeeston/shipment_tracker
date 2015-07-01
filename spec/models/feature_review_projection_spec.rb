require 'rails_helper'

RSpec.describe FeatureReviewProjection do
  let(:builds_projection) {
    instance_double(
      BuildsProjection,
      builds: double(:builds),
    )
  }
  let(:deploys_projection) {
    instance_double(
      DeploysProjection,
      deploys: double(:deploys),
    )
  }
  let(:manual_tests_projection) {
    instance_double(
      ManualTestsProjection,
      qa_submission: double(:qa_submission),
    )
  }
  let(:tickets_projection) {
    instance_double(
      FeatureReviewTicketsProjection,
      tickets: double(:tickets),
      approved?: false,
    )
  }
  let(:uatests_projection) {
    instance_double(
      UatestsProjection,
      uatests: double(:uatests),
    )
  }

  subject(:projection) {
    FeatureReviewProjection.new(
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

  context 'when the tickets projection is approved' do
    let(:tickets_projection) { instance_double(FeatureReviewTicketsProjection, approved?: true) }

    it 'becomes locked' do
      expect(projection).to be_locked
    end

    it 'rejects events' do
      expect(builds_projection).to_not receive(:apply)
      expect(deploys_projection).to_not receive(:apply)
      expect(manual_tests_projection).to_not receive(:apply)
      expect(tickets_projection).to_not receive(:apply)
      expect(uatests_projection).to_not receive(:apply)

      projection.apply(event)
    end

    context 'and then unapproved' do
      let(:event_before_unapproval) { build(:deploy_event) }
      let(:unapproval_event) { build(:jira_event, :rejected) }
      let(:event_after_unapproval) { build(:circle_ci_event) }

      before do
        allow(builds_projection).to receive(:apply)
        allow(deploys_projection).to receive(:apply)
        allow(manual_tests_projection).to receive(:apply)
        allow(tickets_projection).to receive(:apply)
        allow(uatests_projection).to receive(:apply)
      end

      it 'stops rejecting events and also applies the previously rejected ones' do
        projection.apply(event_before_unapproval)

        allow(tickets_projection).to receive(:apply).with(unapproval_event) do
          allow(tickets_projection).to receive(:approved?).and_return(false)
        end

        projection.apply(unapproval_event)

        expect(projection).not_to be_locked

        expect(tickets_projection).to have_received(:apply).with(event_before_unapproval).ordered
        expect(tickets_projection).to have_received(:apply).with(unapproval_event).ordered

        projection.apply(event_after_unapproval)

        expect(tickets_projection).to have_received(:apply).with(event_after_unapproval).ordered
      end
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

  describe '#uatests' do
    it 'delegates to the uatests projection' do
      expect(projection.uatests).to eq(uatests_projection.uatests)
    end
  end
end
