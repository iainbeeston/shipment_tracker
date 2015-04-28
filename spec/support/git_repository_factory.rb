require 'rugged'

module Support
	class GitRepositoryFactory

    attr_reader :dir

    def initialize(dir=Dir.mktmpdir)
      @dir = dir
      @repo = Rugged::Repository.init_at(dir)
      @repo.config['user.name'] = "Unconfigured"
      @repo.config['user.email'] = "unconfigured@example.com"
    end

    def create_commit(author_name:)
      oid = repo.write("This is about #{author_name} at #{Time.now}", :blob)
      index = repo.index

      index.read_tree(repo.head.target.tree) unless repo.empty?
      index.add(path: "README.md", oid: oid, mode: 0100644)

      options = {}
      options[:tree] = index.write_tree(repo)

      options[:author] = { email: "#{author_name.parameterize}@example.com", name: author_name, time: Time.now }
      options[:commiter] = { email: "#{author_name.parameterize}@example.com", name: author_name, time: Time.now }
      options[:message] ||= "#{author_name} making a commit"
      options[:parents] = repo.empty? ? [] : [repo.head.target].compact
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(repo, options).tap do |commit|
        commits.push commit
      end
    end

    def commits
      @commits ||= []
    end

    private

    attr_reader :repo

  end
end
