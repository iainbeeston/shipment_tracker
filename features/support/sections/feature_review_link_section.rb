module Sections
  class FeatureReviewLinkSection
    include Virtus.value_object

    values do
      attribute :link, String
    end

    def self.from_element(feature_review_link_element)
      new(
        link: feature_review_link_element[:href],
      )
    end
  end
end
