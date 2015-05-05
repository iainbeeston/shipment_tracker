require 'rails_helper'
require 'git_repository'
require 'support/git_repository_factory'

require 'rugged'

RSpec.describe GitRepository do
  describe '.load' do
    let(:test_git_repo) { Support::GitRepositoryFactory.new }
    let(:cache_dir) { Dir.mktmpdir }

    before do
      test_git_repo.create_commit(author_name: 'first commit')
      RepositoryLocation.create(name: 'some_repo', uri: "file://#{test_git_repo.dir}")
    end

    it 'returns a GitRepository' do
      expect(described_class.load('some_repo', cache_dir: cache_dir)).to be_a(GitRepository)
    end

    it 'should only clone once' do
      expect(Rugged::Repository).to receive(:clone_at).once.and_call_original

      described_class.load('some_repo', cache_dir: cache_dir)
      described_class.load('some_repo', cache_dir: cache_dir)
    end

    it 'should always fetch when repository already cloned' do
      described_class.load('some_repo', cache_dir: cache_dir)

      expect_any_instance_of(Rugged::Repository).to receive(:fetch).once.and_call_original

      described_class.load('some_repo', cache_dir: cache_dir)
    end
  end

  describe '#commits_between' do
    let(:test_git_repo) { Support::GitRepositoryFactory.new }

    subject { described_class.new(Rugged::Repository.new(test_git_repo.dir)) }

    it 'returns all commits between two commits' do
      commit_first  = test_git_repo.create_commit(author_name: 'a', message: 'message 1')
      commit_second = test_git_repo.create_commit(author_name: 'b', message: 'message 2')
      commit_third  = test_git_repo.create_commit(author_name: 'c', message: 'message 3')
      test_git_repo.create_commit(author_name: 'd')

      commits = subject.commits_between(commit_first, commit_third)

      expect(commits).to contain_exactly(
        GitCommit.new(author_name: 'b', id: commit_second, message: 'message 2'),
        GitCommit.new(author_name: 'c', id: commit_third, message: 'message 3')
      )
    end

    context 'when an invalid commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        invalid_commit = 'INVALID!!!'

        expect {
          subject.commits_between(valid_commit, invalid_commit)
        }.to raise_error(GitRepository::CommitNotValid, invalid_commit)
      end
    end

    context 'when a non existent commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        non_existent_commit = '8120765f3fce2da11a5c8e17d3ca800847912424'

        expect {
          subject.commits_between(valid_commit, non_existent_commit)
        }.to raise_error(GitRepository::CommitNotFound, non_existent_commit)
      end
    end
  end
end
