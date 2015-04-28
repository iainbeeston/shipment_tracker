require 'rails_helper'

describe Event do
  describe ".deploys" do
    it "returns the list of deploy events" do
      3.times { Event.create }
      deploy_events = Event.deploys
      expect(deploy_events.count).to eq(3)
    end
  end

  describe ".create_deploy" do
    it "creates a deploy event" do
      expect { Event.create_deploy(deployed_by: "Alice") }.to change { Event.count }.by(1)
      expect(Event.last.details).to eq('deployed_by' => "Alice")
    end
  end
end
