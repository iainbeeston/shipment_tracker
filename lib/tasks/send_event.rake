namespace :send do
  # rake "send:uat_event[true, abc123, uat.fundingcircle.com, http://localhost:1201/events/uat?token=123]"
  desc 'Sends a sample UAT event'
  task :uat_event, [:success, :test_suite_version, :server, :url] do |_, args|
    send_event(
      args[:url],
      success: args[:success] == 'true',
      test_suite_version: args[:test_suite_version],
      server: args[:server],
    )
  end

  # rake send:deploy_event[app1,abc123,uat.fundingcircle.com,http://localhost:1201/events/deploy?token=123]
  desc 'Sends a sample deploy event'
  task :deploy_event, [:app_name, :version, :server, :environment, :url] do |_, args|
    send_event(
      args[:url],
      server: args[:server],
      environment: args[:environment],
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
