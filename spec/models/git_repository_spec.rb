require 'rails_helper'
require 'git_repository'
require 'support/git_test_repository'

require 'rugged'

RSpec.describe GitRepository do
  let(:test_git_repo) { Support::GitTestRepository.new }

  subject(:repo) { GitRepository.new(Rugged::Repository.new(test_git_repo.dir)) }

  describe '#unmerged_commits_matching_query' do
    it 'returns all unmerged commits where the message contains the query' do
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-1 master')

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
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-1 master')

      commits = repo.unmerged_commits_matching_query('ENG-1')

      expect(commits).to contain_exactly(
        build_commit(second_commit),
        build_commit(third_commit),
      )
    end
  end

  describe '#last_unmerged_commit_matching_query' do
    it 'returns last unmerged commit where the message contains the query' do
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-1 master', time: Time.new(2015, 4, 16))
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-2 master')
      test_git_repo.create_branch('foo')
      test_git_repo.create_commit(author_name: 'Bob', message: 'ENG-1 master', time: Time.new(2015, 4, 17))
      test_git_repo.checkout('foo')
      expected_commit = test_git_repo.create_commit(author_name: 'Carol', message: 'ENG-1 foo')
      test_git_repo.create_commit(author_name: 'Alice', message: 'ENG-2 foo')
      test_git_repo.checkout('master')
      test_git_repo.create_commit(author_name: 'Bob', message: 'ENG-1 master')

      expect(repo.last_unmerged_commit_matching_query('ENG-1')).to eq(build_commit(expected_commit))
    end
  end

  describe '#commits_between' do
    it 'returns all commits between two commits' do
      commit_first  = test_git_repo.create_commit(author_name: 'a', message: 'message 1')
      commit_second = test_git_repo.create_commit(author_name: 'b', message: 'message 2')
      commit_third  = test_git_repo.create_commit(author_name: 'c', message: 'message 3')
      test_git_repo.create_commit(author_name: 'd')

      commits = repo.commits_between(commit_first.oid, commit_third.oid)

      expect(commits).to contain_exactly(
        build_commit(commit_second),
        build_commit(commit_third),
      )
    end

    context 'when an invalid commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        invalid_commit_oid = 'INVALID!!!'

        expect {
          repo.commits_between(valid_commit.oid, invalid_commit_oid)
        }.to raise_error(GitRepository::CommitNotValid, invalid_commit_oid)
      end
    end

    context 'when a non existent commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        non_existent_commit_oid = '8120765f3fce2da11a5c8e17d3ca800847912424'

        expect {
          repo.commits_between(valid_commit.oid, non_existent_commit_oid)
        }.to raise_error(GitRepository::CommitNotFound, non_existent_commit_oid)
      end
    end
  end

  describe '#recent_commits' do
    it 'returns specified number of recent commits' do
      test_git_repo.create_commit(author_name: 'a', message: 'message 1')
      commit_second = test_git_repo.create_commit(author_name: 'b', message: 'message 2')
      commit_third  = test_git_repo.create_commit(author_name: 'c', message: 'message 3')
      commit_fourth = test_git_repo.create_commit(author_name: 'd', message: 'message 4')

      commits = repo.recent_commits(3)

      expect(commits).to eq([
        build_commit(commit_fourth),
        build_commit(commit_third),
        build_commit(commit_second),
      ])
    end
  end

  def build_commit(commit)
    GitCommit.new(
      id: commit.oid,
      author_name: commit.author[:name],
      message: commit.message,
      time: commit.time,
    )
  end
end
