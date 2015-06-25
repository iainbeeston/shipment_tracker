require 'support/git_test_repository'

module Support
  class RepositoryBuilder
    def self.build(git_ascii_graph)
      new(Support::GitTestRepository.new).build(git_ascii_graph)
    end

    def initialize(test_git_repo)
      @test_git_repo = test_git_repo
    end

    def build(git_ascii_graph)
      case git_ascii_graph.strip_heredoc
      when example_1
        create_example_1
      when example_2
        create_example_2
      when example_3
        create_example_3
      when example_4
        create_example_4
      else
        fail "Unrecognised:\n#{git_ascii_graph}"
      end

      test_git_repo
    end

    private

    attr_reader :test_git_repo

    def example_1
      <<-'EOS'.strip_heredoc
           o-A-B
          /     \
        -o-------o
      EOS
    end

    def create_example_1
      test_git_repo.create_commit
      test_git_repo.create_branch('branch')
      test_git_repo.checkout_branch('branch')
      test_git_repo.create_commit
      test_git_repo.create_commit(pretend_version: 'A')
      test_git_repo.create_commit(pretend_version: 'B')
      test_git_repo.checkout_branch('master')
      test_git_repo.merge_branch(branch_name: 'branch')
    end

    def example_2
      '-A'
    end

    def create_example_2
      test_git_repo.create_commit(pretend_version: 'A')
    end

    def example_3
      '-o'
    end

    def create_example_3
      test_git_repo.create_commit
    end

    def example_4
      '-A-B-C-o'
    end

    def create_example_4
      test_git_repo.create_commit(pretend_version: 'A')
      test_git_repo.create_commit(pretend_version: 'B')
      test_git_repo.create_commit(pretend_version: 'C')
      test_git_repo.create_commit
    end
  end
end
