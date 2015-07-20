require 'rails_helper'
require 'git_repository_loader'
require 'support/git_test_repository'

RSpec.describe GitRepositoryLoader do
  let(:cache_dir) { Dir.mktmpdir }

  subject(:git_repository_loader) do
    GitRepositoryLoader.new(
      cache_dir: cache_dir,
      ssh_private_key: 'ssh_private_key',
      ssh_public_key: 'ssh_public_key',
      ssh_user: 'ssh_user',
    )
  end

  describe '#load' do
    let(:test_git_repo) { Support::GitTestRepository.new }
    let(:repo_uri) { "file://#{test_git_repo.dir}" }
    let!(:repository_location) { RepositoryLocation.create(name: 'some_repo', uri: repo_uri) }

    context 'when the repository location does not exist' do
      it 'raises a NotFound exception' do
        expect {
          git_repository_loader.load('non-existent-repo')
        }.to raise_error(GitRepositoryLoader::NotFound)
      end
    end

    context 'with a file uri' do
      let(:repo_uri) { "file://#{test_git_repo.dir}" }
      let(:test_git_repo) { Support::GitTestRepository.new }

      before do
        test_git_repo.create_commit
        repository_location.update(remote_head: test_git_repo.head_oid)
      end

      it 'returns a GitRepository' do
        expect(git_repository_loader.load('some_repo')).to be_a(GitRepository)
      end

      context 'when the repository has not been cloned yet' do
        it 'should clone it' do
          expect(Rugged::Repository).to receive(:clone_at).once.and_call_original

          git_repository_loader.load('some_repo')
        end
      end

      context 'when the repository has already been cloned' do
        before do
          git_repository_loader.load('some_repo')
        end

        context 'if the local copy is up-to-date' do
          it 'should do nothing' do
            expect(Rugged::Repository).to_not receive(:clone_at)
            expect_any_instance_of(Rugged::Repository).to_not receive(:fetch)

            git_repository_loader.load('some_repo')
          end
        end

        context 'if the local copy is not up-to-date' do
          before do
            create_remote_commit
          end

          it 'should fetch it' do
            expect(Rugged::Repository).to_not receive(:clone_at)
            expect_any_instance_of(Rugged::Repository).to receive(:fetch).once.and_call_original

            git_repository_loader.load('some_repo')
          end
        end
      end

      it 'should not use credentials' do
        expect(Rugged::Repository).to receive(:clone_at) do |_uri, _dir, options|
          expect(options).to_not have_key(:credentials)
        end

        git_repository_loader.load('some_repo')
      end
    end

    context 'when the destination directory is not empty and is not a git repo' do
      it 'removes the destination directory before cloning' do
        git_repository = git_repository_loader.load('some_repo')

        # Screw up the git repository
        path = git_repository.path
        FileUtils.rm_rf(path)
        Dir.mkdir(path)
        File.open(File.join(path, 'foo.txt'), 'w') do |f| f.write('foo') end

        # Reload the git repository
        expect { git_repository_loader.load('some_repo') }.not_to raise_error
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

      it 'should raise an error when ssh_private_key missing' do
        expect {
          GitRepositoryLoader.new(
            cache_dir: cache_dir,
            ssh_public_key: 'public_key',
            ssh_private_key: nil,
            ssh_user: 'user',
          ).load('some_repo')
        }.to raise_error('ssh_private_key not set')
      end

      it 'should raise an error when ssh_public_key missing' do
        expect {
          GitRepositoryLoader.new(
            cache_dir: cache_dir,
            ssh_public_key: nil,
            ssh_private_key: 'private_key',
            ssh_user: 'user',
          ).load('some_repo')
        }.to raise_error('ssh_public_key not set')
      end

      it 'should raise an error when ssh_user missing' do
        expect {
          GitRepositoryLoader.new(
            cache_dir: cache_dir,
            ssh_public_key: 'public_key',
            ssh_private_key: 'key',
            ssh_user: nil,
          ).load('some_repo')
        }.to raise_error('ssh_user not set')
      end
    end

    context 'for an SSH URI with credentials' do
      let(:expected_private_key) { 'PR1V4t3' }
      let(:expected_public_key) { 'PU8L1C' }
      let(:expected_username) { 'fran' }
      let(:repo_uri) { 'ssh://example.com/some_repo.git' }

      subject(:git_repository_loader) do
        GitRepositoryLoader.new(
          cache_dir: cache_dir,
          ssh_private_key: expected_private_key,
          ssh_public_key: expected_public_key,
          ssh_user: expected_username,
        )
      end

      it 'should use the correct credentials when using SSH' do
        private_key_file = nil
        public_key_file = nil

        expect(Rugged::Repository).to receive(:clone_at) do |uri, _directory, options|
          # This is a Rugged::Credentials object which is a C extension
          # We need to delve into the internals of this to check it is the correct credentials object\
          # that is being passed to the clone method
          credentials = options.fetch(:credentials)
          username = credentials.instance_variable_get(:@username)
          private_key_file = credentials.instance_variable_get(:@privatekey)
          public_key_file = credentials.instance_variable_get(:@publickey)

          expect(uri).to eq(repo_uri)

          expect(username).to eq(expected_username)

          expect(File.read(private_key_file)).to eq(expected_private_key + "\n")
          expect(File.stat(private_key_file)).to_not be_world_readable

          expect(File.read(public_key_file)).to eq(expected_public_key + "\n")
          expect(File.stat(public_key_file)).to_not be_world_readable
        end

        git_repository_loader.load('some_repo')

        expect(File.exist?(private_key_file)).to be(false), 'The privatekey file should be cleaned up'
      end
    end
  end

  def create_remote_commit
    test_git_repo.create_commit
    repository_location.update(remote_head: test_git_repo.head_oid)
  end
end
