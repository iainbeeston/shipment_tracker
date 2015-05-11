class Deploy
  include Virtus.value_object

  values do
    attribute :server, String
    attribute :version, String
    attribute :deployed_by, String
  end
end
