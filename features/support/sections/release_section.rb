module Sections
  class ReleaseSection
    include Virtus.value_object

    values do
      attribute :id, String
      attribute :date, Time
      attribute :message, String
    end

    def self.from_element(release_element)
      values = release_element.all('td').map(&:text).to_a
      new(
        id:      values.fetch(0),
        date:    values.fetch(1),
        message: values.fetch(2),
      )
    end
  end
end
