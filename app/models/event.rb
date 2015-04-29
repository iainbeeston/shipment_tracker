class Event < ActiveRecord::Base
  def self.deploys
    all
  end

  def self.create_deploy(message:)
    Event.create(details: { type: 'deploy', message: message })
  end
end
