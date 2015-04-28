require 'rails_helper'
require 'git_repository'
require 'support/git_repository_factory'

require 'rugged'

RSpec.describe GitRepository do
  describe '#author_names_between' do
    let(:test_git_repo) { Support::GitRepositoryFactory.new }

    subject { described_class.new(Rugged::Repository.new(test_git_repo.dir)) }

    it 'returns all authors names between two commits' do
      alfred_commit = test_git_repo.create_commit(author_name: 'alfred')
      bobby_commit = test_git_repo.create_commit(author_name: 'bobby')
      carl_commit =  test_git_repo.create_commit(author_name: 'carl')
      david_commit = test_git_repo.create_commit(author_name: 'david')

      author_names = subject.author_names_between(alfred_commit, carl_commit)

      expect(author_names).to contain_exactly('bobby', 'carl')
    end

    it 'ommits duplcated author names' do
      alfred_commit = test_git_repo.create_commit(author_name: 'alfred')
      bobby_commit = test_git_repo.create_commit(author_name: 'bobby')
                     test_git_repo.create_commit(author_name: 'bobby')
      carl_commit = test_git_repo.create_commit(author_name: 'carl')
      david_commit = test_git_repo.create_commit(author_name: 'david')

      author_names = subject.author_names_between(alfred_commit, carl_commit)

      expect(author_names).to contain_exactly('bobby', 'carl')
    end
  end
end
