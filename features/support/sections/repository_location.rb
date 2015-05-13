module Sections
  class RepositoryLocation
    include Virtus.value_object

    values do
      attribute :name, String
      attribute :uri, String
    end

    def self.from_element(repository_location_element)
      values = repository_location_element.all('td').map(&:text).to_a
      new(
        name: values.fetch(0),
        uri:  values.fetch(1),
      )
    end
  end
end
