class Ticket
  include Virtus.value_object

  APPROVED_STATUSES = ['Done', 'Ready for Deployment'].freeze

  values do
    attribute :key, String
    attribute :summary, String, default: ''
    attribute :status, String, default: 'To Do'
    attribute :approver_email, String
    attribute :approved_at, Time
  end

  def approved?
    APPROVED_STATUSES.include?(status)
  end

  def update_attributes(new_attributes)
    Ticket.new(attributes.merge(new_attributes))
  end
end
