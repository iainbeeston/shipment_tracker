class Release
  include Virtus.value_object

  values do
    attribute :commit, GitCommit
    attribute :feature_review_path, String
  end
end
