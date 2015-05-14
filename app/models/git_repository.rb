require 'rugged'

class GitRepository
  class CommitNotFound < StandardError; end
  class CommitNotValid < StandardError; end

  def initialize(repository)
    @repository = repository
  end

  def commits_between(from, to)
    validate_commit!(from) unless from.nil?
    validate_commit!(to)

    walker = Rugged::Walker.new(repository)
    walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
    walker.push(to)
    walker.hide(from) if from

    build_commits(walker)
  end

  private

  def build_commits(commits)
    commits.map { |c| GitCommit.new(id: c.oid, author_name: c.author[:name], message: c.message) }
  end

  def validate_commit!(commit)
    fail CommitNotFound, commit unless commit.present? && repository.exists?(commit)
  rescue Rugged::InvalidError
    raise CommitNotValid, commit
  end

  attr_reader :repository
end
