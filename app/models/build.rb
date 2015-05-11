class Build
  include Virtus.value_object

  values do
    attribute :source, String
    attribute :status, String
    attribute :version, String
  end
end
