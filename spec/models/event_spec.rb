require 'rails_helper'

describe Event do
  describe '.in_order_of_creation' do
    it 'returns all Events in ascending created_at order' do
      middle = FactoryGirl.create(:deploy_event)
      first = FactoryGirl.create(:circle_ci_event, created_at: 3.days.ago)
      last = FactoryGirl.create(:jenkins_event, created_at: 3.days.from_now)

      expect(Event.in_order_of_creation.to_a).to eq([first, middle, last])
    end
  end
end
