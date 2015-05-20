module Pages
  class PrepareFeatureReviewPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def visit
      page.visit url_helpers.new_feature_review_path
    end

    def add(field_name:, content:)
      page.fill_in(field_name, with: content)
    end

    def submit
      page.click_link_or_button('Submit')
    end

    private

    attr_reader :page, :url_helpers
  end
end
