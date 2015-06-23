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

  def releases_page
    Pages::ReleasesPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers,
    )
  end
end

World(Pages)
