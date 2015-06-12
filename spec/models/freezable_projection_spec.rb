require 'rails_helper'

class DummyProjection
  attr_reader :events

  def initialize
    @events = []
    @approved = false
  end

  def apply(event)
    @events << event
  end

  def apply_all(events)
    @events += events
  end

  def approve!
    @approved = true
  end

  def unapprove!
    @approved = false
  end
end

RSpec.describe FreezableProjection do
  let(:projection) { DummyProjection.new }

  subject(:freezable_projection) { FreezableProjection.new(projection) }

  xdescribe '#apply_all' do
    let(:event_before_freezing) { build(:deploy_event) }
    let(:freezing_event) { build(:jira_event, :rejected) }
    let(:event_after_freezing) { build(:deploy_event) }
    let(:unfreezing_event) { build(:jira_event, :rejected) }
    let(:event_after_unfreezing) { build(:circle_ci_event) }

    context 'when the projection is frozen' do
      let!(:events) {
        [
          event_before_freezing,
          freezing_event,
          event_after_freezing,
        ]
      }

      it 'ignores events following the ticket approval' do
        expect(projection).to receive(:apply).with(event_before_freezing).and_call_original
        expect(projection).to receive(:apply).with(freezing_event).and_call_original

        freezable_projection.apply_all(events)
      end
    end

    context 'when the frozen projection is unfrozen' do
      before do
        freezable_projection.apply(freezing_event)
      end

      it 'applies all events since freezing' do
        # expect(projection).to receive(:apply_all).with([event_after_freezing]).ordered
        # expect(projection).to receive(:apply).with(unfreezing_event).ordered
        # expect(projection).to receive(:apply).with(event_after_unfreezing).ordered

        freezable_projection.apply_all(event_after_freezing)

        freezable_projection.apply(unfreezing_event)
        freezable_projection.apply(event_after_unfreezing)
      end
    end
  end
end
