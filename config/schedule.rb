every 10.minutes, roles: [:cron] do
  rake 'jobs:update_git', output: File.join(path, 'log', 'jobs.log')
end
