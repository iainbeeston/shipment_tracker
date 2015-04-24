Rails.application.routes.draw do
  get 'heartbeat', to: 'heartbeat#index'
end
