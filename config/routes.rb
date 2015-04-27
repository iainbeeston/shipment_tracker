Rails.application.routes.draw do

  get 'heartbeat', to: 'heartbeat#index'

  get 'release_audits', to: 'release_audits#index'
  root 'release_audits#index'
end
