Rails.application.routes.draw do
  root 'release_audits#index'

  get 'heartbeat', to: 'heartbeat#index'

  resources :release_audits, only: :show
  resources :deploys, only: [:index, :create]
end
