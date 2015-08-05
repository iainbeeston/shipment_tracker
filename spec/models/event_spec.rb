require 'rails_helper'

RSpec.describe Event do
  describe '.in_order_of_creation' do
    it 'returns all Events in insertion order' do
      first = create(:circle_ci_event)
      middle = create(:jenkins_event)
      last = create(:deploy_event)

      expect(Event.in_order_of_creation.to_a).to eq([first, middle, last])
    end
  end

  describe '.between' do
    let(:times) { [2.hours.ago, 1.hour.ago, 1.minute.ago] }
    let(:events) { times.map { |t| build(:circle_ci_event, created_at: t) } }

    before do
      events.each(&:save!)
    end

    context 'when nil is specified' do
      it 'returns all events' do
        expect(Event.between(0).to_a).to eq(events)
      end
    end

    context 'when an integer is specified' do
      it 'returns events greater than that id' do
        expect(Event.between(events.second.id).to_a).to eq(events[2..-1])
      end
    end

    context 'when up_to is also specified' do
      it 'returns all events up to the time specified' do
        expect(Event.between(0, up_to: events[1].created_at).to_a).to eq(events.slice(0..1))
      end
    end
  end
end
