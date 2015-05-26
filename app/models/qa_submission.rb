class QaSubmission
  include Virtus.value_object

  values do
    attribute :name, String
    attribute :status, String
    attribute :created_at, Time
  end
end
