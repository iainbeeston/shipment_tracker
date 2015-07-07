require 'rails_helper'

RSpec.describe RepositoryLocationsController do
  context 'when logged out' do
    let(:repository_location) {
      {
        'name' => 'shipment_tracker',
        'uri' => 'https://github.com/FundingCircle/shipment_tracker.git',
      }
    }

    it { is_expected.to require_authentication_on(:get, :index) }
    it { is_expected.to require_authentication_on(:post, :create, repository_location: repository_location) }
  end
end
