require 'rails_helper'

RSpec.describe FreezableProjection do
  let(:projection) { instance_double(FeatureReviewProjection) }

  subject(:freezable_projection) { FreezableProjection.new(projection) }

  let(:event_before_freezing) { build(:deploy_event) }
  let(:freezing_event) { build(:jira_event, :done) }
  let(:event_after_freezing) { build(:deploy_event) }

  let(:events) {
    [
      event_before_freezing,
      freezing_event,
      event_after_freezing,
    ]
  }

  context 'when the projection is frozen' do
    it 'ignores events following the ticket approval' do
      expect(projection).to receive(:apply).with(event_before_freezing).ordered
      expect(projection).to receive(:apply).with(freezing_event).ordered
      expect(projection).to_not receive(:apply).with(event_after_freezing).ordered

      freezable_projection.apply_all(events)
    end
  end

  context 'when the frozen projection is unfrozen' do
    let(:unfreezing_event) { build(:jira_event, :rejected) }
    let(:event_after_unfreezing) { build(:circle_ci_event) }

    let(:events) {
      [
        event_before_freezing,
        freezing_event,
        event_after_freezing,
        unfreezing_event,
        event_after_unfreezing,
      ]
    }

    it 'applies all events since freezing' do
      expect(projection).to receive(:apply).with(event_before_freezing).ordered
      expect(projection).to receive(:apply).with(freezing_event).ordered
      expect(projection).to receive(:apply).with(event_after_freezing).ordered
      expect(projection).to receive(:apply).with(unfreezing_event).ordered
      expect(projection).to receive(:apply).with(event_after_unfreezing).ordered

      freezable_projection.apply_all(events)
    end
  end
end
