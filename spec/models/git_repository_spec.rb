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

  xdescribe '#author_names_between' do
    let(:test_git_repo) { Support::GitRepositoryFactory.new }

    subject { described_class.new(Rugged::Repository.new(test_git_repo.dir)) }

    it 'returns all authors names between two commits' do
      alfred_commit = test_git_repo.create_commit(author_name: 'alfred')
      test_git_repo.create_commit(author_name: 'bobby')
      carl_commit = test_git_repo.create_commit(author_name: 'carl')
      test_git_repo.create_commit(author_name: 'david')

      author_names = subject.author_names_between(alfred_commit, carl_commit)

      expect(author_names).to contain_exactly('bobby', 'carl')
    end

    it 'omits duplicated author names' do
      alfred_commit = test_git_repo.create_commit(author_name: 'alfred')
      test_git_repo.create_commit(author_name: 'bobby')
      test_git_repo.create_commit(author_name: 'bobby')
      carl_commit = test_git_repo.create_commit(author_name: 'carl')
      test_git_repo.create_commit(author_name: 'david')

      author_names = subject.author_names_between(alfred_commit, carl_commit)

      expect(author_names).to contain_exactly('bobby', 'carl')
    end

    context 'when an invalid commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        invalid_commit = 'INVALID!!!'

        expect {
          subject.author_names_between(valid_commit, invalid_commit)
        }.to raise_error(GitRepository::CommitNotValid, invalid_commit)
      end
    end

    context 'when a non existent commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit(author_name: 'foo')
        non_existent_commit = '8120765f3fce2da11a5c8e17d3ca800847912424'

        expect {
          subject.author_names_between(valid_commit, non_existent_commit)
        }.to raise_error(GitRepository::CommitNotFound, non_existent_commit)
      end
    end
  end
end
