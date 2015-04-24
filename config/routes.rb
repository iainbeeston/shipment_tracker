Rails.application.routes.draw do
  root 'heartbeat#index'
  get 'heartbeat', to: 'heartbeat#index'
end
