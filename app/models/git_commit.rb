class GitCommit
  include Virtus.value_object

  values do
    attribute :id, String
    attribute :author_name, String
  end
end
