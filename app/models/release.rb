class Release
  include Virtus.value_object

  values do
    attribute :commit, GitCommit
    attribute :feature_review_url, String
  end
end
