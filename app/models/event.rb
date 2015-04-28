class Event < ActiveRecord::Base
  def self.deploys
    all
  end

  def self.create_deploy(deployed_by:)
    Event.create(details: { deployed_by: deployed_by })
  end
end
