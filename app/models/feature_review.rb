class FeatureReview
  include Virtus.value_object

  values do
    attribute :url, String
    attribute :versions, Array
    attribute :status, String
  end
end
