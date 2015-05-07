module Sections
  class TicketSection
    include Virtus.value_object

    values do
      attribute :id, String
    end

    def self.from_element(ticket_element)
      values = ticket_element.all('td').map(&:text).to_a
      new(
        id: values.fetch(0),
      )
    end
  end
end
