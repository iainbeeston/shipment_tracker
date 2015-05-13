require 'rails_helper'

describe HeartbeatController do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to eq('ok')
    end
  end
end
