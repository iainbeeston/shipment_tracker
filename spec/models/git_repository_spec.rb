require 'rails_helper'
require 'git_repository'
require 'support/git_test_repository'

require 'rugged'

RSpec.describe GitRepository do
  let(:test_git_repo) { Support::GitTestRepository.new }
  let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
  subject(:repo) { GitRepository.new(rugged_repo) }

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

    describe 'branch selection' do
      let(:sample_commit) { test_git_repo.create_commit(author_name: 'b', message: 'message 2') }
      let(:production_branch) {}
      let(:master_branch) { double('branch', target_id: '123') }
      let(:local_master_branch) { double('branch', target_id: '123') }

      before do
        allow(rugged_repo).to receive(:branches).and_return(branches)
      end

      context 'when there is a remote production branch' do
        let(:branches) {
          {
            'origin/production' => double('branch', target_id: sample_commit.oid),
            'origin/master' => double('branch'),
            'master' => double('branch'),
          }
        }

        it 'returns commits from origin/production' do
          expect(repo.recent_commits(3)).to eq([build_commit(sample_commit)])
        end
      end

      context 'when there is a remote master branch, but no remote production' do
        let(:branches) {
          {
            'origin/master' => double('branch', target_id: sample_commit.oid),
            'master' => double('branch'),
          }
        }

        it 'returns commits from origin/master' do
          expect(repo.recent_commits(3)).to eq([build_commit(sample_commit)])
        end
      end

      context 'when there are no remote branches called production or master' do
        let(:branches) {
          {
            'origin/other' => double('branch'),
            'master' => double('branch', target_id: sample_commit.oid),
          }
        }

        it 'returns commits from master' do
          expect(repo.recent_commits(3)).to eq([build_commit(sample_commit)])
        end
      end
    end
  end

  describe '#get_dependents' do
    it 'returns the ancestors of a commit up to the merge base' do
      test_git_repo.create_commit(author_name: 'Alice', message: 'master 1')
      test_git_repo.create_branch('branch')
      test_git_repo.checkout_branch('branch')
      branch_1 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 1')
      branch_2 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 2')
      branch_3 = test_git_repo.create_commit(author_name: 'Alice', message: 'branch 3')
      test_git_repo.create_commit(author_name: 'Alice', message: 'branch 4')
      test_git_repo.checkout_branch('master')
      test_git_repo.create_commit(author_name: 'Alice', message: 'master 2')
      test_git_repo.merge_branch(branch_name: 'branch', author_name: 'Alice', time: Time.now)

      expect(repo.get_dependents(branch_3.oid)).to contain_exactly(
        build_commit(branch_2),
        build_commit(branch_1),
      )
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
