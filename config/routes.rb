Rails.application.routes.draw do
  root 'home#index'

  get '/auth/auth0/callback', to: 'sessions#auth0_success_callback'
  get '/auth/failure', to: 'sessions#auth0_failure_callback'
  delete '/sessions', to: 'sessions#destroy'

  # Events
  post 'events/:type', to: 'events#create', as: 'events'

  # Projections
  resources :feature_reviews, only: [:new, :index]
  resources :releases, only: [:index, :show]

  resources :repository_locations, only: [:index, :create]
end
