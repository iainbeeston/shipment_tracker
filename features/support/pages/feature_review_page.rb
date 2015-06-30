module Pages
  class FeatureReviewPage
    def initialize(page:, url_helpers:)
      @page        = page
      @url_helpers = url_helpers
    end

    def app_info
      verify!
      page.all('.app-info li.app').map { |app_info_element|
        Sections::AppInfoSection.from_element(app_info_element)
      }
    end

    def builds
      verify!
      page.all('.build').map { |build_line|
        Sections::BuildSection.from_element(build_line)
      }
    end

    def uat_url
      verify!
      page.find('.uat-url').text
    end

    def panel_heading_status(panel_class)
      verify!
      page.find(".panel.#{panel_class}")[:class].match(/panel-(?<status>\w+)/)[:status]
    end

    def deploys
      verify!
      page.all('.deploy').map { |deploy_line|
        Sections::FeatureReviewDeploySection.from_element(deploy_line)
      }
    end

    def create_qa_submission(status:, comment:)
      verify!
      page.choose(status.capitalize)
      page.fill_in('Comment', with: comment)
      page.click_link_or_button('Submit')
    end

    def qa_submission
      verify!
      Sections::QaSubmissionSection.from_element(page.find('.qa-submission'))
    end

    def tickets
      verify!
      Sections::TableSection.new(page.find('.tickets table')).items
    end

    def summary_contents
      verify!
      page.all('.summary li').map { |summary_line| Sections::SummarySection.from_element(summary_line) }
    end

    def locked?
      verify!
      page.all('.icon-lock').any?
    end

    private

    attr_reader :page, :url_helpers

    def verify!
      fail "Expected to be on a Feature Review page, but was on #{page.current_url}" unless on_page?
    end

    def on_page?
      page.current_url =~ Regexp.new(Regexp.escape(url_helpers.feature_reviews_path))
    end
  end
end
