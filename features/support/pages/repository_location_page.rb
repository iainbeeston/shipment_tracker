module Pages
  class RepositoryLocationPage
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
      Sections::TableSection.new(page.find('table.repository_locations')).items
    end

    private

    attr_reader :page, :url_helpers
  end
end
