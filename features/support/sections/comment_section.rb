module Sections
  class CommentSection
    include Virtus.value_object

    values do
      attribute :message, String
      attribute :name, String
    end

    def self.from_element(comment_element)
      values = comment_element.all('td').map(&:text).to_a
      new(
        name: values.fetch(0),
        message: values.fetch(1),
      )
    end
  end
end
