require 'rugged'
require 'active_support/inflector/transliterate'

module Support
  class GitTestCommit
    attr_reader :version, :pretend_version

    def initialize(version, pretend_version)
      @version = version
      @pretend_version = pretend_version
    end
  end

  class GitTestRepository
    include ActiveSupport::Inflector

    attr_reader :dir

    delegate :checkout, to: :repo

    def initialize(dir = Dir.mktmpdir)
      @dir = File.realpath(dir)
      @repo = Rugged::Repository.init_at(dir)
      @repo.config['user.name'] = 'Unconfigured'
      @repo.config['user.email'] = 'unconfigured@example.com'
      @now = Time.at(0)
    end

    def create_commit(author_name: 'Alice', pretend_version: nil, message: 'A new commit', time: nil)
      oid = repo.write('file contents', :blob)
      index = repo.index

      index.read_tree(repo.head.target.tree) unless repo.empty?
      index.add(path: 'README.md', oid: oid, mode: 0100644)
      oid = index.write_tree(repo)

      @now += 60
      time ||= @now

      create_rugged_commit(
        tree_oid: oid,
        message: message,
        author_name: author_name,
        time: time,
      ).tap do |commit|
        commits.push GitTestCommit.new(commit.oid, pretend_version)
      end
    end

    def create_branch(branch_name)
      repo.create_branch(branch_name) unless repo.branches.exist?(branch_name)
    end

    def checkout_branch(branch_name)
      repo.checkout(branch_name)
    end

    def merge_branch(branch_name:, author_name: 'Alice', time: Time.now, pretend_version: nil)
      master_tip_oid = repo.branches['master'].target_id
      branch_tip_oid = repo.branches[branch_name].target_id
      merge_index = repo.merge_commits(master_tip_oid, branch_tip_oid)

      fail 'Conflict detected!' if merge_index.conflicts?

      create_rugged_commit(
        tree_oid: merge_index.write_tree(repo),
        message: "Merged `#{branch_name}` into `master`",
        author_name: author_name,
        time: time,
        parents: [master_tip_oid, branch_tip_oid],
      ).tap do |commit|
        commits.push GitTestCommit.new(commit.oid, pretend_version)
      end
    end

    def commit_for_pretend_version(pretend_version)
      commit = commits.find { |c| c.pretend_version == pretend_version }
      commit && commit.version
    end

    def commits
      @commits ||= []
    end

    private

    attr_reader :repo

    def create_rugged_commit(tree_oid:, message:, author_name:, time:, parents: nil)
      parents ||= repo.empty? ? [] : [repo.head.target].compact

      commit_oid = Rugged::Commit.create(
        repo,
        tree: tree_oid,
        message: message,
        author: author(author_name, time),
        committer: author(author_name, time),
        parents: parents,
        update_ref: 'HEAD',
      )

      repo.lookup(commit_oid)
    end

    def author(author_name, time)
      { email: "#{parameterize(author_name)}@example.com", name: author_name, time: time }
    end
  end
end
