class DeploysController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Deploy.create(details: params)
    head :ok
  end
end
