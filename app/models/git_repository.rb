require 'rugged'

class GitRepository
  def self.author_names_for(repository_name:, to:, from: nil)
    return [] unless to
    loader = self.load(repository_name)
    loader.author_names_between(from, to)
  end

  def self.load(repository_name)
    remote_repository = Repository.find_by_name(repository_name)
    dir = Dir.mktmpdir

    repository = Rugged::Repository.clone_at(
       remote_repository.uri,
       dir
    )

    self.new(repository)
  end

  def initialize(repository)
    @repository = repository
  end

  def author_names_between(from, to)
    commits_between(from, to).map {|c| c.author[:name] }.uniq
  end

  private

  def commits_between(from, to)
    walker = Rugged::Walker.new(repository)
    walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
    walker.push(to)
    walker.hide(from) if from
    walker
  end

  attr_reader :repository
end
