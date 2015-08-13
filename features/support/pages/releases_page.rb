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

    def method_missing(method_name)
      if method_name.to_s =~ /(.*)_releases$/
        releases(Regexp.last_match(1))
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.end_with?('_releases') || super
    end

    private

    def releases(deploy_status)
      verify!
      page.all(".#{deploy_status}-release").map { |release_line|
        values = release_line.all('td').to_a
        {
          'version' => values.fetch(0).text,
          'time' => Time.parse(values.fetch(1).text),
          'subject' => values.fetch(2).text,
          'approved' => !release_line['class'].split.include?('danger'),
          'feature_review_status' => values.fetch(3).text,
          'feature_review_path' => extract_href_if_exists(values.fetch(3)),
        }
      }
    end

    def extract_href_if_exists(element)
      element.find('a')['href'] if element.has_css?('a')
    end

    def verify!
      fail "Expected to be on a Feature Review page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.releases_path))
    end

    attr_reader :page, :url_helpers
  end
end
