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

    def authors
      page.all('.author').map(&:text)
    end

    def comment(message:, name:)
      page.fill_in :message, with: message
      page.fill_in :name, with: name
      page.click_link_or_button('Comment')
      self
    end

    def comments
      page.all('.comment').map { |comment_line| Sections::CommentSection.from_element(comment_line) }
    end

    def deploys
      page.all('.deploy').map { |deploy_line| Sections::DeploySection.from_element(deploy_line) }
    end

    def builds
      page.all('.build').map { |build_line| Sections::BuildSection.from_element(build_line) }
    end

    def tickets
      page.all('.ticket').map { |ticket_line| Sections::TicketSection.from_element(ticket_line) }
    end

    private

    attr_reader :page, :url_helpers
  end
end
