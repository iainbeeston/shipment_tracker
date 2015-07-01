module Sections
  class SummarySection
    include Virtus.value_object

    values do
      attribute :title, String
      attribute :status, String
    end

    def self.from_element(build_element)
      status_classes = {
        'text-success' => 'success',
        'text-danger'  => 'failed',
        'text-warning' => 'n/a',
      }

      classes = build_element.find('.status')[:class].split
      status_class = (classes & status_classes.keys).first
      new(
        title:  build_element.find('.title').text,
        status: status_classes.fetch(status_class),
      )
    end
  end
end
