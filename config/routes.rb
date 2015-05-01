Rails.application.routes.draw do
  root 'heartbeat#index'

  get 'heartbeat', to: 'heartbeat#index'

  resources :deploys, only: :create
  resources :feature_audits, only: :show
end
