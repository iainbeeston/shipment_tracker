module Pages
  def feature_audit_page
    Pages::FeatureAuditPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers
    )
  end

  def error_message
    Pages::ErrorMessage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers
    )
  end
end

World(Pages)
