module Sections
  class UatestsSection
    include Virtus.value_object

    values do
      attribute :status, String
      attribute :test_suite_version, String
    end

    def self.from_element(uatests_element)
      status_classes = {
        'panel-success' => 'success',
        'panel-danger'  => 'failed',
        'panel-warning' => 'n/a',
      }

      classes = uatests_element[:class].split
      status_class = (classes & status_classes.keys).first

      new(
        status: status_classes.fetch(status_class),
        test_suite_version: uatests_element.find('.uat-version').text,
      )
    end
  end
end
