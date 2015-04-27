module Pages
  def release_audit_page
    Pages::ReleaseAuditPage.new(
      page: page,
      url_helpers: Rails.application.routes.url_helpers)
  end
end

World(Pages)
