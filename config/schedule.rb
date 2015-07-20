every 10.minutes, roles: [:cron_events_worker] do
  rake 'jobs:update_events'
end

every 10.minutes, roles: [:cron] do
  rake 'jobs:update_git'
end
