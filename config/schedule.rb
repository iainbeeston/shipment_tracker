every 10.minutes, roles: [:db] do
  rake 'jobs:update_events'
end
