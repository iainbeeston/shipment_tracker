class Ticket
  include Virtus.value_object

  values do
    attribute :key, String
    attribute :summary, String
    attribute :status, String
    attribute :approver_email, String
  end

  def update_attributes(new_attributes)
    Ticket.new(attributes.merge(new_attributes))
  end
end
