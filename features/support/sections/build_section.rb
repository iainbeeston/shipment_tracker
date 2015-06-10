module Sections
  class BuildSection
    include Virtus.value_object

    values do
      attribute :status, String
      attribute :app,    String
      attribute :source, String
    end

    def self.from_element(build_element)
      status_classes = {
        'text-success' => 'success',
        'text-danger'  => 'failed',
        'text-warning' => 'n/a',
      }

      values = build_element.all('td').to_a
      status_class = values.fetch(0).find('.status')[:class].split.last
      new(
        status:  status_classes.fetch(status_class),
        app:     values.fetch(1).text,
        source:  values.fetch(2).text,
      )
    end
  end
end
