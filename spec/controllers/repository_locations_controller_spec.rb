require 'rails_helper'

RSpec.describe RepositoryLocationsController do
  describe 'GET #index', skip_login: true do
    it 'requires login' do
      expect_any_instance_of(ApplicationController).to receive(:require_authentication).at_least(1).times
      get :index
    end
  end

  describe 'POST #create', skip_login: true do
    it 'requires login' do
      expect_any_instance_of(ApplicationController).to receive(:require_authentication).at_least(1).times
      post :create, repository_location: {
        'name' => 'shipment_tracker',
        'uri' => 'https://github.com/FundingCircle/shipment_tracker.git',
      }
    end
  end
end
