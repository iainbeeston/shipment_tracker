module Sections
  class TicketSection
    include Virtus.value_object

    values do
      attribute :key, String
      attribute :summary, String
      attribute :status, String
      attribute :approver_email, String
      attribute :approved_at, String
    end

    def self.from_element(ticket_element)
      values = ticket_element.all('td').map(&:text).to_a
      new(
        key: values.fetch(0),
        summary: values.fetch(1),
        status: values.fetch(2),
        approver_email: values.fetch(3),
        approved_at: values.fetch(4),
      )
    end
  end
end
