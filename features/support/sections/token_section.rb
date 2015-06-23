module Sections
  class TokenSection
    include Virtus.value_object

    values do
      attribute :source, String
      attribute :url, String
    end

    def self.from_element(token_element)
      values = token_element.all('td').to_a
      new(
        source: values.fetch(0).text,
        url: values.fetch(1).text,
      )
    end
  end
end
