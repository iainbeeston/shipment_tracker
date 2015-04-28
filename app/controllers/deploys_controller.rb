class DeploysController < ApplicationController
  def index
    @deploy_events = Event.deploys
  end

  def create
    Event.create_deploy(deployed_by: params.fetch('deployed_by'))
    head :ok
  end
end

