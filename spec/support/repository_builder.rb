require 'support/git_test_repository'

require 'securerandom'

module Support
  class RepositoryBuilder
    def self.build(git_ascii_graph)
      new(Support::GitTestRepository.new).build(git_ascii_graph)
    end

    def initialize(test_git_repo)
      @test_git_repo = test_git_repo
    end

    class << self
      def add_example(diagram, code)
        examples[diagram] = code
      end

      def examples
        @examples ||= {}
      end
    end

    def build(git_ascii_graph)
      self.class.examples.fetch(git_ascii_graph.strip_heredoc) {
        fail "Unrecognised git tree:\n#{git_ascii_graph}"
      }.call(test_git_repo)
      test_git_repo
    end

    private

    attr_reader :test_git_repo
  end
end

Support::RepositoryBuilder.add_example(
  '-A',
  proc do |repo|
    repo.create_commit(pretend_version: 'A')
  end,
)

Support::RepositoryBuilder.add_example(
  '-A-B-C-o',
  proc do |repo|
    repo.create_commit(pretend_version: 'A')
    repo.create_commit(pretend_version: 'B')
    repo.create_commit(pretend_version: 'C')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
           o-A-B---
          /        \
        -o-------o--C---o
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.checkout_branch('master')
    repo.create_commit
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'B')
    repo.checkout_branch('master')
    repo.merge_branch(branch_name: branch_name, pretend_version: 'C')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
          o-A----B
         /        \
        -o-----o----C---o
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.checkout_branch('master')
    repo.create_commit
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'B')
    repo.checkout_branch('master')
    repo.merge_branch(branch_name: branch_name, pretend_version: 'C')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
             B--C----E
            /         \
      -o---A-------D---F---G-
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'B')
    repo.create_commit(pretend_version: 'C')
    repo.checkout_branch('master')
    repo.create_commit(pretend_version: 'D')
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'E')
    repo.checkout_branch('master')
    repo.merge_branch(branch_name: branch_name, pretend_version: 'F')
    repo.create_commit(pretend_version: 'G')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  '-A-o',
  proc do |repo|
    repo.create_commit(pretend_version: 'A')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  '-o-A-o',
  proc do |repo|
    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
           o-A-o
          /
        -o-----o
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.create_commit
    repo.checkout_branch('master')
    repo.create_commit
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
           A-B-C-o
          /       \
        -o----o----o
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'A')
    repo.create_commit(pretend_version: 'B')
    repo.create_commit(pretend_version: 'C')
    repo.create_commit
    repo.checkout_branch('master')
    repo.create_commit
    repo.merge_branch(branch_name: branch_name)
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
           A-B
          /   \
        -o--o--C
      EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'A')
    repo.create_commit(pretend_version: 'B')
    repo.checkout_branch('master')
    repo.create_commit
    repo.merge_branch(branch_name: branch_name, pretend_version: 'C')
  end,
)

Support::RepositoryBuilder.add_example(
  '-o-A-B-C',
  proc do |repo|
    repo.create_commit
    repo.create_commit(pretend_version: 'A')
    repo.create_commit(pretend_version: 'B')
    repo.create_commit(pretend_version: 'C')
  end,
)

Support::RepositoryBuilder.add_example(
  <<-'EOS'.strip_heredoc,
       A-B
      /   \
    -o-----C---D
  EOS
  proc do |repo|
    branch_name = "branch-#{SecureRandom.hex(10)}"

    repo.create_commit
    repo.create_branch(branch_name)
    repo.checkout_branch(branch_name)
    repo.create_commit(pretend_version: 'A')
    repo.create_commit(pretend_version: 'B')
    repo.checkout_branch('master')
    repo.merge_branch(branch_name: branch_name, pretend_version: 'C')
    repo.create_commit(pretend_version: 'D')
  end,
)
