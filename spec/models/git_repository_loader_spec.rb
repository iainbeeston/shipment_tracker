require 'rails_helper'
require 'git_repository_loader'
require 'support/git_repository_factory'

RSpec.describe GitRepositoryLoader do
  let(:cache_dir) { Dir.mktmpdir }

  subject(:git_repository_loader) do
    GitRepositoryLoader.new(
      cache_dir: cache_dir,
      ssh_key: 'ssh_key',
      ssh_user: 'ssh_user',
    )
  end

  describe '#load' do
    let(:repo_uri) { "file://#{test_git_repo.dir}" }

    before do
      RepositoryLocation.create(name: 'some_repo', uri: repo_uri)
    end

    context 'with a file uri' do
      let(:test_git_repo) { Support::GitRepositoryFactory.new }

      before do
        test_git_repo.create_commit(author_name: 'first commit')
      end

      it 'returns a GitRepository' do
        expect(git_repository_loader.load('some_repo')).to be_a(GitRepository)
      end

      it 'should only clone once' do
        expect(Rugged::Repository).to receive(:clone_at).once.and_call_original

        git_repository_loader.load('some_repo')
        git_repository_loader.load('some_repo')
      end

      it 'should always fetch when repository already cloned' do
        git_repository_loader.load('some_repo')

        expect_any_instance_of(Rugged::Repository).to receive(:fetch).once.and_call_original

        git_repository_loader.load('some_repo')
      end

      it 'should not use credentials' do
        expect(Rugged::Repository).to receive(:clone_at) do |_uri, _dir, options|
          expect(options).to_not have_key(:credentials)
        end

        git_repository_loader.load('some_repo')
      end
    end

    context 'with a http uri' do
      let(:repo_uri) { 'http://example.com/foo.git' }

      it 'should not use credentials' do
        expect(Rugged::Repository).to receive(:clone_at) do |_uri, _dir, options|
          expect(options).to_not have_key(:credentials)
        end

        git_repository_loader.load('some_repo')
      end
    end

    context 'for an SSH URI without credentials' do
      let(:repo_uri) { 'ssh://example.com/some_repo.git' }

      before do
        allow(Rugged::Repository).to receive(:clone_at)
        allow_any_instance_of(Rugged::Repository).to receive(:fetch)
      end

      it 'should raise an error when ssh_key missing' do
        expect {
          GitRepositoryLoader.new(
            cache_dir: cache_dir,
            ssh_key: nil,
            ssh_user: 'user',
          ).load('some_repo')
        }.to raise_error('ssh_key not set')
      end

      it 'should raise an error when ssh_user missing' do
        expect {
          GitRepositoryLoader.new(
            cache_dir: cache_dir,
            ssh_key: 'key',
            ssh_user: nil,
          ).load('some_repo')
        }.to raise_error('ssh_user not set')
      end
    end

    context 'for an SSH URI' do
      let(:expected_privatekey) { 'PR1V4t3' }
      let(:expected_username) { 'fran' }
      let(:repo_uri) { 'ssh://example.com/some_repo.git' }

      subject(:git_repository_loader) do
        GitRepositoryLoader.new(
          cache_dir: cache_dir,
          ssh_key: expected_privatekey,
          ssh_user: expected_username,
        )
      end

      it 'should use the correct credentials when using SSH' do
        privatekey_file = nil

        expect(Rugged::Repository).to receive(:clone_at) do |uri, _directory, options|
          # This is a Rugged::Credentials object which is a C extension
          # We need to delve into the internals of this to check it is the correct credentials object\
          # that is being passed to the clone method
          credentials = options.fetch(:credentials)
          username = credentials.instance_variable_get(:@username)
          privatekey_file = credentials.instance_variable_get(:@privatekey)

          expect(uri).to eq(repo_uri)
          expect(username).to eq(expected_username)
          expect(File.read(privatekey_file)).to eq(expected_privatekey)
          expect(File.stat(privatekey_file)).to_not be_world_readable
        end

        git_repository_loader.load('some_repo')

        expect(File.exist?(privatekey_file)).to be(false), 'The privatekey file should be cleaned up'
      end
    end
  end
end
