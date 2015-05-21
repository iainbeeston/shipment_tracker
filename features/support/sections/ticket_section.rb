module Sections
  class TicketSection
    include Virtus.value_object

    values do
      attribute :key, String
      attribute :summary, String
      attribute :description, String
      attribute :status, String
      attribute :approver_email, String
      attribute :approved_at, String
    end

    def self.from_element(ticket_element)
      values = ticket_element.all('td').map(&:text).to_a
      new(
        key: values.fetch(0),
        summary: values.fetch(1),
        description: values.fetch(2),
        status: values.fetch(3),
        approver_email: values.fetch(4, nil),
        approved_at: values.fetch(5, nil),
      )
    end
  end
end
