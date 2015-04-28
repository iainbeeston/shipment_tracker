RepositoryLocation.find_or_create_by(name: 'shipment_tracker') do |repository_location|
  repository_location.uri = 'https://github.com/FundingCircle/shipment_tracker.git'
end

RepositoryLocation.find_or_create_by(name: 'hello_world_rails') do |repository_location|
  repository_location.uri = 'https://github.com/FundingCircle/hello_world_rails.git'
end
