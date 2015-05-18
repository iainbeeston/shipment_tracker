module Sections
  class AppInfoSection
    include Virtus.value_object

    values do
      attribute :app_name, String
      attribute :version, String
    end

    def self.from_element(app_info_element)
      values = app_info_element.all('td').map(&:text).to_a
      new(
        app_name:  values.fetch(0),
        version:  values.fetch(1),
      )
    end
  end
end
