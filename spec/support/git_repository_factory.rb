require 'rugged'

module Support
  class GitCommit
    attr_reader :version, :pretend_version
    def initialize(version, pretend_version)
      @version = version
      @pretend_version = pretend_version
    end
  end

  class GitRepositoryFactory
    attr_reader :dir

    def initialize(dir = Dir.mktmpdir)
      @dir = dir
      @repo = Rugged::Repository.init_at(dir)
      @repo.config['user.name'] = "Unconfigured"
      @repo.config['user.email'] = "unconfigured@example.com"
    end

    def create_commit(author_name:, pretend_version: nil)
      oid = repo.write("This is about #{author_name} at #{Time.now}", :blob)
      index = repo.index

      index.read_tree(repo.head.target.tree) unless repo.empty?
      index.add(path: "README.md", oid: oid, mode: 0100644)
      oid = index.write_tree(repo)

      Rugged::Commit.create(
        repo,
        commit_options(author_name, oid)
      ).tap do |commit|
        commits.push GitCommit.new(commit, pretend_version)
      end
    end

    def commit_for_pretend_version(pretend_version)
      commit = commits.find { |c| c.pretend_version == pretend_version }
      fail "Commit not found for #{c.pretend_version}. Commits available: #{commits.inspect}" unless commit
      commit.version
    end

    def commits
      @commits ||= []
    end

    private

    attr_reader :repo

    def commit_options(author_name, oid)
      {
        tree: oid,
        author: author(author_name),
        commiter: author(author_name),
        message: "#{author_name} making a commit",
        parents: repo.empty? ? [] : [repo.head.target].compact,
        update_ref: 'HEAD'
      }
    end

    def author(author_name)
      { email: "#{author_name.parameterize}@example.com", name: author_name, time: Time.now }
    end
  end
end
