Rails.application.routes.draw do
  root 'heartbeat#index'

  get 'heartbeat', to: 'heartbeat#index'

  post 'events/circle', to: 'ci#circle'

  resources :deploys, only: :create
  resources :feature_audits, only: :show
end
