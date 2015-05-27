require 'rails_helper'

RSpec.describe ReleasesController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    xit 'returns http success' do
      get :show, id: 'app_name'
      expect(response).to have_http_status(:success)
    end
  end
end
