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

  describe '.after_id' do
    it 'returns all events greater than id' do
      event1 = create(:circle_ci_event)
      event2 = create(:jenkins_event)
      event3 = create(:deploy_event)

      expect(Event.after_id(event1.id).to_a).to eq([event2, event3])
    end
  end
end
