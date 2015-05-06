module Sections
  class BuildSection
    include Virtus.value_object

    values do
      attribute :status, String
      attribute :version, String
    end

    def self.from_element(build_element)
      values = build_element.all('td').map(&:text).to_a
      new(
        status:  values.fetch(0),
        version: values.fetch(1),
      )
    end
  end
end
