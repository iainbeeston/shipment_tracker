module Pages
  class TokensPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def visit
      page.visit url_helpers.tokens_path
    end

    def generate_token_for(source)
      verify!
      page.fill_in 'Source', with: source
      page.click_on 'Create Token'
    end

    def tokens
      verify!
      page.all('.token').map { |token_line|
        Sections::TokenSection.from_element(token_line)
      }
    end

    private

    def verify!
      fail "Expected to be on a Tokens page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.tokens_path))
    end

    attr_reader :page, :url_helpers
  end
end
