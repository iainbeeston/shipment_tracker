require 'git_repository'
require 'rugged'

module Services
  class GitLoader
    def initialize(repositories:, dir:)
      @repositories = repositories
      @dir = dir
    end

    def get(repo_name)
      # if exists
        # if fresh
        #   load
        # else
        #   fetch
        # end
        # else

      repo = Rugged::Repository.clone_at(
        repositories.fetch(repo_name),
        File.join(dir, String(repo_name))
      )
      GitRepository.new(repo)
    end
    private
    attr_reader :dir, :repositories
  end
end
