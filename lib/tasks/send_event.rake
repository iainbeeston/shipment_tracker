namespace :send do
  # rake "send:uat_event[success, abc123, uat.fundingcircle.com, http://localhost:1201/events/uat?token=123]"
  desc 'Sends a sample UAT event'
  task :uat_event, [:status, :test_suite_version, :server, :url] do |_, args|
    send_event(
      args[:url],
      status: args[:status],
      test_suite_version: args[:test_suite_version],
      server: args[:server],
    )
  end

  # rake send:deploy_event[app1,abc123,uat.fundingcircle.com,http://localhost:1201/events/deploy?token=123]
  desc 'Sends a sample deploy event'
  task :deploy_event, [:app_name, :version, :server, :url] do |_, args|
    send_event(
      args[:url],
      server: args[:server],
      version: args[:version],
      app_name: args[:app_name],
    )
  end

  def send_event(url, payload)
    command = "curl -H 'Content-Type: application/json' -X POST -d '#{payload.to_json}' #{url}"
    puts command
    system command
  end
end
