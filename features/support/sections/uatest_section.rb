module Sections
  class UatestSection
    include Virtus.value_object

    values do
      attribute :status, String
      attribute :test_suite_version, String
    end

    def self.from_element(uatest_element)
      status_classes = {
        'panel-success' => 'success',
        'panel-danger'  => 'failed',
        'panel-warning' => 'n/a',
      }

      classes = uatest_element[:class].split
      status_class = (classes & status_classes.keys).first

      new(
        status: status_classes.fetch(status_class),
        test_suite_version: uatest_element.find('.uat-version').text,
      )
    end
  end
end
