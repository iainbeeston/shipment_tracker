require 'rails_helper'

RSpec.describe TokensController do
  let(:tokens) { [Token.new] }

  before do
    allow(Token).to receive(:all).and_return(tokens)
  end

  describe 'GET #index', skip_login: true do
    it 'shows the list of tokens' do
      get :index

      expect(assigns(:tokens)).to eq(tokens)
      expect(assigns(:token)).to be_a(Token)
      expect(assigns(:token)).to be_a_new_record
    end
  end

  describe 'POST #create', skip_login: true do
    it 'creates a new token' do
      expect(Token).to receive(:create).with(source: 'circleci')

      post :create, token: { source: 'circleci' }

      expect(response).to redirect_to(tokens_path)
    end
  end
end
