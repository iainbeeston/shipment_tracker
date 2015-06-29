module Pages
  def repository_location_page
    Pages::RepositoryLocationPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def prepare_feature_review_page
    Pages::PrepareFeatureReviewPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def feature_review_page
    Pages::FeatureReviewPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def feature_review_search_page
    Pages::FeatureReviewSearchPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def releases_page
    Pages::ReleasesPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def tokens_page
    Pages::TokensPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end

  def error_message
    Pages::ErrorMessage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end
end

World(Pages)
