module Pages
  class FeatureAuditPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def request(project_name:, from: nil, to: nil)
      page.visit url_helpers.feature_audit_path(project_name)
      fail "Error \"#{error_message.text}\" was found on the page" if error_message.present?

      if to
        page.fill_in :from, with: from
        page.fill_in :to, with: to
        page.click_link_or_button('Submit')
      end
      self
    end

    def authors
      verify!
      page.all('.author').map(&:text)
    end

    def comment(message:, name:)
      verify!
      page.fill_in :message, with: message
      page.fill_in :name, with: name
      page.click_link_or_button('Comment')
      self
    end

    def comments
      verify!
      page.all('.comment').map { |comment_line| Sections::CommentSection.from_element(comment_line) }
    end

    def deploys
      verify!
      page.all('.deploy').map { |deploy_line| Sections::DeploySection.from_element(deploy_line) }
    end

    def builds
      verify!
      page.all('.build').map { |build_line| Sections::BuildSection.from_element(build_line) }
    end

    def tickets
      verify!
      page.all('.ticket').map { |ticket_line| Sections::TicketSection.from_element(ticket_line) }
    end

    private

    attr_reader :page, :url_helpers

    def verify!
      fail "Expected to be on a Feature Audit page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.feature_audit_path(id: '')))
    end

    def error_present?
      error_message.present?
    end

    def error_message
      @error_message ||= ErrorMessage.new(page: page, url_helpers: url_helpers)
    end
  end
end
