every 10.minutes, roles: [:cron_events_worker] do
  rake 'jobs:update_events', output: File.join(path, 'log', 'jobs.log')
end

every 10.minutes, roles: [:cron] do
  rake 'jobs:update_git', output: File.join(path, 'log', 'jobs.log')
end
