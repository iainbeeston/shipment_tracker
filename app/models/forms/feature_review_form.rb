module Forms
  class FeatureReviewForm
    extend ActiveModel::Naming
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    attr_reader :uat_url, :apps

    def to_key
      nil
    end

    def initialize(apps:, git_repository_loader: nil, uat_url:)
      @apps = apps
      @git_repository_loader = git_repository_loader
      @uat_url = uat_url
    end

    def valid?
      apps.each do |repo_name, version|
        begin
          repo = git_repository_loader.load(repo_name.to_s)
          errors.add(repo_name, "version #{version} does not exist") unless repo.exists?(version)
        rescue GitRepositoryLoader::NotFound
          errors.add(repo_name, 'does not exist')
        end
      end
      errors.empty?
    end

    def url
      hash = {}
      hash[:apps] = apps
      hash[:uat_url] = uat_url if uat_url.present?
      "/feature_reviews?#{hash.to_query}"
    end

    def apps
      @apps.select { |_app_name, version| version.present? }
    end

    private

    attr_reader :git_repository_loader
  end
end
