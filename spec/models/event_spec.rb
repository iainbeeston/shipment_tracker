require 'rails_helper'

describe Event do
  describe '.in_order_of_creation' do
    it 'returns all Events in ascending id order' do
      first = FactoryGirl.create(:circle_ci_event, id: 1)
      last = FactoryGirl.create(:jenkins_event, id: 3)
      middle = FactoryGirl.create(:deploy_event, id: 2)

      expect(Event.in_order_of_creation.to_a).to eq([first, middle, last])
    end
  end
end
