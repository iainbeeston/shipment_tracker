module Sections
  class DeploySection
    include Virtus::ValueObject

    attribute :server, String
    attribute :version, String
    attribute :deployed_at, String
    attribute :deployed_by, String

    def self.from_element(deploy_element)
      values = deploy_element.all('td').map(&:text).to_a
      new(
        server:      values.fetch(0),
        version:     values.fetch(1),
        deployed_at: values.fetch(2),
        deployed_by: values.fetch(3)
      )
    end
  end
end
