module Sections
  class ShortCommitSha < Virtus::Attribute
    def coerce(value)
      value[0...7]
    end
  end

  class FeatureReviewDeploySection
    include Virtus.value_object

    values do
      attribute :app_name, String
      attribute :version, ShortCommitSha
      attribute :correct, String
    end

    def self.from_element(deploy_element)
      correct_classes = {
        'text-success' => 'yes',
        'text-danger'  => 'no',
        'text-warning' => '',
      }

      values = deploy_element.all('td').to_a
      correct_class = values.fetch(0).find('.status')[:class].split.last
      new(
        correct:  correct_classes.fetch(correct_class),
        app_name: values.fetch(1).text,
        version:  values.fetch(2).text,
      )
    end
  end
end
