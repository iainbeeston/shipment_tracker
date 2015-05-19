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

  # Returns an array of GitCommits where the commit message includes the query
  # and the commit doesn't exist on the master branch.
  def unmerged_commits_matching_query(query)
    rugged_commits = repository.each_id
                     .map { |id| repository.lookup(id) }
                     .select { |o| o.type == :commit }
                     .select { |c| c.message.include?(query) }
                     .reject { |c| merged_commit_oid?(c.oid) }
    build_commits(rugged_commits)
  end

  def last_unmerged_commit_matching_query(query)
    unmerged_commits_matching_query(query).max_by(&:time)
  end

  private

  def build_commit(commit)
    GitCommit.new(
      id: commit.oid,
      author_name: commit.author[:name],
      message: commit.message,
      time: commit.time,
    )
  end

  def build_commits(commits)
    commits.map { |c| build_commit(c) }
  end

  def validate_commit!(commit_oid)
    fail CommitNotFound, commit_oid unless repository.exists?(commit_oid)
  rescue Rugged::InvalidError
    raise CommitNotValid, commit_oid
  end

  def merged_commit_oid?(commit_oid)
    master_oid = (repository.branches['master'] || repository.branches['origin/master']).target_id
    commit_oid == master_oid || repository.descendant_of?(master_oid, commit_oid)
  end

  attr_reader :repository
end
