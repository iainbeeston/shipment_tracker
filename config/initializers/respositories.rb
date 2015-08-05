Rails.configuration.repositories = [
  Repositories::FeatureReviewRepository.new,
  Repositories::DeployRepository.new,
  Repositories::BuildRepository.new,
  Repositories::ManualTestRepository.new,
  Repositories::TicketRepository.new,
  # This must always be last as it depends on DeployRepository.
  # Until we make snapshot updating more robust (e.g. jobs queue or table locking) this will have to remain.
  Repositories::UatestRepository.new,
]
