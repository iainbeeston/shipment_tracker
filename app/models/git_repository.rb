require 'rugged'

class GitRepository
  class CommitNotFound < StandardError; end
  class CommitNotValid < StandardError; end

  def initialize(repository)
    @repository = repository
  end

  def commits_between(from, to)
    instrument('commits_between') do
      validate_commit!(from) unless from.nil?
      validate_commit!(to)

      walker = Rugged::Walker.new(repository)
      walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
      walker.push(to)
      walker.hide(from) if from

      build_commits(walker)
    end
  end

  def recent_commits(count = 50)
    walker = Rugged::Walker.new(repository)
    walker.sorting(Rugged::SORT_TOPO)
    walker.push(main_branch.target_id)

    build_commits(walker.take(count))
  end

  # Returns an array of GitCommits where the commit message includes the query
  # and the commit doesn't exist on the master branch.
  def unmerged_commits_matching_query(query)
    instrument('unmerged_commits_matching_query') do
      rugged_commits = repository.each_id
                       .map { |id| repository.lookup(id) }
                       .select { |o| o.type == :commit }
                       .select { |c| c.message.include?(query) }
                       .reject { |c| merged_commit_oid?(c.oid) }
      build_commits(rugged_commits)
    end
  end

  def last_unmerged_commit_matching_query(query)
    instrument('last_unmerged_commit_matching_query') do
      unmerged_commits_matching_query(query).max_by(&:time)
    end
  end

  def get_dependent_commits(commit_oid)
    master = main_branch.target

    dependent_commits = []
    common_ancestor_oid = nil
    loop do
      common_ancestor_oid = repository.merge_base(master.oid, commit_oid)
      break unless common_ancestor_oid == commit_oid
      dependent_commits << build_commit(master) if master.parent_ids.second == commit_oid
      master = master.parents.first
    end

    dependent_commits + commits_between(common_ancestor_oid, commit_oid)[0...-1]
  end

  private

  attr_reader :repository

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
    master_oid = main_branch.target_id
    commit_oid == master_oid || repository.descendant_of?(master_oid, commit_oid)
  end

  def instrument(name, &block)
    ActiveSupport::Notifications.instrument(
      "#{name}.git_repository",
      &block
    )
  end

  def main_branch
    repository.branches['origin/production'] ||
      repository.branches['origin/master'] ||
      repository.branches['master']
  end
end
