module Pages
  class RepositoryLocation
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def visit
      page.visit url_helpers.repository_locations_path
    end

    def fill_in(name:, uri:)
      page.fill_in 'Name', with: name
      page.fill_in 'URI', with: uri
      page.click_link_or_button('Create Repository location')
      self
    end

    def repository_locations
      page.all('.repository_location').map { |e| Sections::RepositoryLocation.from_element(e) }
    end

    private

    attr_reader :page, :url_helpers
  end
end
