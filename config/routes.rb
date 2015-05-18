Rails.application.routes.draw do
  root 'heartbeat#index'

  # Status
  get 'heartbeat', to: 'heartbeat#index'

  # Events
  post 'events/:type', to: 'events#create', as: 'events'
  post 'deploys', to: 'events#create', defaults: { type: 'deploy' } # Legacy while we transition

  # Projections
  resources :feature_audits, only: :show
  resources :issue_audits, only: [:index, :show]
  resources :feature_reviews, only: [:new, :index]

  resources :repository_locations, only: [:index, :create]
end
