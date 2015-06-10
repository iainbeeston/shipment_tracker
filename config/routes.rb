Rails.application.routes.draw do
  root 'home#index'

  # Status
  # get 'heartbeat', to: 'heartbeat#index'

  # Events
  post 'events/:type', to: 'events#create', as: 'events'
  post 'deploys', to: 'events#create', defaults: { type: 'deploy' } # Legacy while we transition

  # Projections
  resources :feature_reviews, only: [:new, :index]
  resources :releases, only: [:index, :show]

  resources :repository_locations, only: [:index, :create]
end
