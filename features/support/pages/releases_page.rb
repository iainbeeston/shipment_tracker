module Pages
  class ReleasesPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def visit(app)
      page.visit url_helpers.releases_path
      page.click_on(app)
    end

    def releases
      verify!
      page.all('.release').map { |release_line|
        Sections::ReleaseSection.from_element(release_line)
      }
    end

    private

    def verify!
      fail "Expected to be on a Feature Review page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.releases_path))
    end

    attr_reader :page, :url_helpers
  end
end
