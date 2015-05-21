module Sections
  class FeatureReviewDeploySection
    include Virtus.value_object

    values do
      attribute :app_name, String
      attribute :version, String
      attribute :correct, String
    end

    def self.from_element(deploy_element)
      values = deploy_element.all('td').map(&:text).to_a
      new(
        app_name: values.fetch(0),
        version:  values.fetch(1),
        correct:  values.fetch(2),
      )
    end
  end
end
