module Pages
  class PrepareFeatureReviewPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def visit
      page.visit url_helpers.new_feature_review_path
    end

    def add(app_name:, version:)
      page.fill_in(app_name, with: version)
    end

    def submit
      page.click_link_or_button('Submit')
    end

    private

    attr_reader :page, :url_helpers
  end
end
