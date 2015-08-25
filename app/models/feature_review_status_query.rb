class FeatureReviewStatusQuery
  def initialize(feature_review, at:)
    @feature_review = feature_review
    @ticket_repository = Repositories::TicketRepository.new
    @time = at
  end

  def tickets
    @tickets ||= ticket_repository.tickets_for(projection_url: feature_review.url, at: time)
  end
end
