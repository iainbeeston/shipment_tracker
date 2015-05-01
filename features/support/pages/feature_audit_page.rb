module Pages
  class FeatureAuditPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def request(project_name:, from: nil, to: nil)
      page.visit url_helpers.feature_audit_path(project_name)
      if to
        page.fill_in :from, with: from
        page.fill_in :to, with: to
        page.click_link_or_button('Submit')
      end
      self
    end

    def authors
      page.all('.author').map(&:text)
    end

    def deploys
      page.all('.deploy').map { |deploy_line| Sections::DeploySection.from_element(deploy_line) }
    end

    private

    attr_reader :page, :url_helpers
  end
end
