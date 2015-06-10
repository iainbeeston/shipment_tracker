class Ticket
  include Virtus.value_object

  values do
    attribute :key, String
    attribute :summary, String, default: ''
    attribute :status, String, default: 'To Do'
    attribute :approver_email, String
    attribute :approved_at, Time
  end

  def approved?
    approver_email.present? && approved_at.present?
  end

  def update_attributes(new_attributes)
    Ticket.new(attributes.merge(new_attributes))
  end
end
