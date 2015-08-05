Rails.configuration.repositories = [
  Repositories::FeatureReviewRepository.new,
  Repositories::DeployRepository.new,
  Repositories::BuildRepository.new,
  Repositories::ManualTestRepository.new,
  Repositories::TicketRepository.new,
  Repositories::UatestRepository.new,
]
