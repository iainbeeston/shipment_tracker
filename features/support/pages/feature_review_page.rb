module Pages
  class FeatureReviewPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def app_info
      page.find('.app_info').map { |app_info_element|
        Sections::AppInfoSection.from_element(app_info_element)
      }
    end

    private

    attr_reader :page, :url_helpers
  end
end
