class DeploysController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @deploy_events = Event.deploys
  end

  def create
    Event.create_deploy(deployed_by: params.fetch('deployed_by'))
    head :ok
  end
end
