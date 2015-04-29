require 'rugged'

class GitRepository
  class CommitNotFound < StandardError; end
  class CommitNotValid < StandardError; end

  def self.author_names_for(repository_name:, to:, from: nil)
    return [] unless to
    loader = load(repository_name)
    loader.author_names_between(from, to)
  end

  def self.load(repository_name, cache_dir: Dir.tmpdir)
    remote_repository = RepositoryLocation.find_by_name(repository_name)
    dir = File.join(cache_dir, "#{remote_repository.id}-#{repository_name}")

    repository = begin
      Rugged::Repository.new(dir).tap { |r| r.fetch('origin') }
    rescue Rugged::OSError, Rugged::RepositoryError
      Rugged::Repository.clone_at(remote_repository.uri, dir)
    end

    new(repository)
  end

  def initialize(repository)
    @repository = repository
  end

  def author_names_between(from, to)
    validate_commit!(from) unless from.nil?
    validate_commit!(to)

    commits_between(from, to).map { |c| c.author[:name] }.uniq
  end

  private

  def commits_between(from, to)
    walker = Rugged::Walker.new(repository)
    walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
    walker.push(to)
    walker.hide(from) if from
    walker
  end

  def validate_commit!(commit)
    fail CommitNotFound, commit unless repository.exists?(commit)
  rescue Rugged::InvalidError
    raise CommitNotValid, commit
  end

  attr_reader :repository
end
