module Sections
  class SummarySection
    include Virtus.value_object

    values do
      attribute :title, String
      attribute :status, String
    end

    def self.from_element(build_element)
      new(
        title:  build_element.find('.title').text,
        status: build_element.find('.status')[:class].split.last,
      )
    end

    def self.from_hash(summary_item)
      status_classes = {
        'success' => 'text-success',
        'failed' => 'text-danger',
        'n/a' => 'text-warning',
      }

      new(
        status: status_classes.fetch(summary_item.fetch('status')),
        title: summary_item.fetch('title'),
      )
    end
  end
end
