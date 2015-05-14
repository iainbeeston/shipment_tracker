require 'rugged'
require 'active_support/inflector/transliterate'

module Support
  class GitCommit
    attr_reader :version, :pretend_version

    def initialize(version, pretend_version)
      @version = version
      @pretend_version = pretend_version
    end
  end

  class GitRepositoryFactory
    include ActiveSupport::Inflector

    attr_reader :dir

    delegate :create_branch, :checkout, to: :repo

    def initialize(dir = Dir.mktmpdir)
      @dir = dir
      @repo = Rugged::Repository.init_at(dir)
      @repo.config['user.name'] = 'Unconfigured'
      @repo.config['user.email'] = 'unconfigured@example.com'
    end

    def create_commit(author_name:, pretend_version: nil, message: 'A new commit')
      oid = repo.write('file contents', :blob)
      index = repo.index

      index.read_tree(repo.head.target.tree) unless repo.empty?
      index.add(path: 'README.md', oid: oid, mode: 0100644)
      oid = index.write_tree(repo)

      Rugged::Commit.create(
        repo,
        commit_options(author_name, oid, message),
      ).tap do |commit|
        commits.push GitCommit.new(commit, pretend_version)
      end
    end

    def commit_for_pretend_version(pretend_version)
      commit = commits.find { |c| c.pretend_version == pretend_version }
      fail "Commit not found for #{pretend_version}. Commits available: #{commits.inspect}" unless commit
      commit.version
    end

    def commits
      @commits ||= []
    end

    private

    attr_reader :repo

    def commit_options(author_name, oid, message)
      {
        tree: oid,
        author: author(author_name),
        commiter: author(author_name),
        message: message,
        parents: repo.empty? ? [] : [repo.head.target].compact,
        update_ref: 'HEAD',
      }
    end

    def author(author_name)
      { email: "#{parameterize(author_name)}@example.com", name: author_name, time: Time.now }
    end
  end
end
