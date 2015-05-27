module Sections
  class ReleaseSection
    include Virtus.value_object

    values do
      attribute :message, String
    end

    def self.from_element(release_element)
      values = release_element.all('td').map(&:text).to_a
      new(
        message: values.fetch(0),
      )
    end
  end
end
