module Pages
  class IssueAuditPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def request(issue_name:)
      page.visit url_helpers.root_path
      page.click_link_or_button 'Issues'
      page.fill_in :issue_name, with: issue_name
      page.click_link_or_button('View issue audit')
      self
    end

    def application_names
      page.all('.application_name').map(&:text)
    end

    def authors(for_app: nil)
      verify!
      app_container(for_app).all('.author').map(&:text)
    end

    def builds(for_app: nil)
      verify!
      app_container(for_app).all('.build').map { |build_line|
        Sections::BuildSection.from_element(build_line)
      }
    end

    def tickets
      verify!
      page.all('.ticket').map { |ticket_line| Sections::TicketSection.from_element(ticket_line) }
    end

    private

    attr_reader :page, :url_helpers

    def verify!
      fail "Expected to be on a Issue Audit page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.issue_audit_path(id: '')))
    end

    def app_container(app_name)
      return page unless app_name
      page.find(".#{app_name}")
    end
  end
end
