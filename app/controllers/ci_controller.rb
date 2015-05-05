class CiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def circle
    CircleCi.create(details: params)
    head :ok
  end
end
