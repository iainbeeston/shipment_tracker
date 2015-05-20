module Sections
  class BuildSection
    include Virtus.value_object

    values do
      attribute :source, String
      attribute :status, String
      attribute :version, String
    end

    def self.from_element(build_element)
      values = build_element.all('td').map(&:text).to_a
      new(
        source:  values.fetch(0),
        status:  values.fetch(1),
        version: values.fetch(2, nil),
      )
    end
  end
end
