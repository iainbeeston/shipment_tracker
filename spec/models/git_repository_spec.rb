require 'rails_helper'
require 'git_repository'
require 'support/git_repository_factory'

require 'rugged'

RSpec.describe GitRepository do
  let(:test_git_repo) { Support::GitRepositoryFactory.new }

  subject(:repo) { GitRepository.new(Rugged::Repository.new(test_git_repo.dir)) }

  describe '#commits_matching_query' do
    it 'returns all commits where the message contains the query' do
      first_commit = test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-1 master')

      test_git_repo.create_branch('foo')
      test_git_repo.checkout('foo')
      second_commit = test_git_repo.create_commit(author_name: 'Bob', message: 'ENG-1 foo')
      test_git_repo.create_commit(author_name: 'Bob', message: 'ENG-2 foo')

      test_git_repo.checkout('master')
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-2 master')

      test_git_repo.create_branch('bar')
      test_git_repo.checkout('bar')
      third_commit = test_git_repo.create_commit(author_name: 'Carol', message: 'ENG-1 bar')
      test_git_repo.create_commit(author_name: 'Carol', message: 'ENG-2 bar')

      test_git_repo.checkout('master')
      fourth_commit = test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-1 master')

      commits = repo.commits_matching_query('ENG-1')

      expect(commits).to contain_exactly(
        GitCommit.new(author_name: 'Alice', id: first_commit, message: 'ENG-1 master'),
        GitCommit.new(author_name: 'Bob', id: second_commit, message: 'ENG-1 foo'),
        GitCommit.new(author_name: 'Carol', id: third_commit, message: 'ENG-1 bar'),
        GitCommit.new(author_name: 'Alice', id: fourth_commit, message: 'ENG-1 master'),
      )
    end
  end

  describe '#commits_between' do
    it 'returns all commits between two commits' do
      commit_first  = test_git_repo.create_commit(author_name: 'a', message: 'message 1')
      commit_second = test_git_repo.create_commit(author_name: 'b', message: 'message 2')
      commit_third  = test_git_repo.create_commit(author_name: 'c', message: 'message 3')
      test_git_repo.create_commit(author_name: 'd')

      commits = repo.commits_between(commit_first, commit_third)

      expect(commits).to contain_exactly(
        GitCommit.new(author_name: 'b', id: commit_second, message: 'message 2'),
        GitCommit.new(author_name: 'c', id: commit_third, message: 'message 3'),
      )
    end

    context 'when an invalid commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        invalid_commit = 'INVALID!!!'

        expect {
          repo.commits_between(valid_commit, invalid_commit)
        }.to raise_error(GitRepository::CommitNotValid, invalid_commit)
      end
    end

    context 'when a non existent commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        non_existent_commit = '8120765f3fce2da11a5c8e17d3ca800847912424'

        expect {
          repo.commits_between(valid_commit, non_existent_commit)
        }.to raise_error(GitRepository::CommitNotFound, non_existent_commit)
      end
    end
  end
end
