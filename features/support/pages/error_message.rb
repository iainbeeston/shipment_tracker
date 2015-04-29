module Pages
  class ErrorMessage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def text
      page.all(selector).map(&:text).join("\n")
    end

    def present?
      page.all(selector).any?
    end

    private

    attr_reader :page, :url_helpers

    def selector
      '.flash.error'
    end
  end
end
