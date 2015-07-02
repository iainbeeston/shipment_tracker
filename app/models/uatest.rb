class Uatest
  include Virtus.value_object

  values do
    attribute :status, String
    attribute :test_suite_version, String
  end
end
