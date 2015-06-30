class QaSubmission
  include Virtus.value_object

  values do
    attribute :email, String
    attribute :comment, String
    attribute :status, String
    attribute :created_at, Time
  end
end
