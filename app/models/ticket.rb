class Ticket
  include Virtus.value_object

  values do
    attribute :key, String
    attribute :summary, String
    attribute :description, String
    attribute :status, String
    attribute :approver_email, String
    attribute :approved_at, Time
  end

  def update_attributes(new_attributes)
    Ticket.new(attributes.merge(new_attributes))
  end
end
