class Release
  include Virtus.value_object

  values do
    attribute :version, String
    attribute :time, String
    attribute :subject, String
    attribute :feature_review_status, String
    attribute :feature_review_path, String
    attribute :approved, Boolean
  end
end
