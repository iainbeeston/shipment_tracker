require 'rails_helper'
require 'git_loader'

RSpec.describe Services::GitLoader do
  describe '#get' do
    context 'when the repo does not exist' do
      let(:repo_url) { 'https://repo_name.com/foo.git' }
      let(:service_root_directory) { Dir.mktmpdir }
      let(:repo) { instance_double(Rugged::Repository) }
      let(:git_repository) { instance_double(GitRepository) }

      subject(:git_loader) {
        described_class.new(
          repositories: {repo_name: repo_url},
          dir: service_root_directory
        )
      }

      it 'checks it out and returns a GitRepository' do
        repo_root_directory = File.join(service_root_directory, 'repo_name')

        expect(Rugged::Repository).to receive(:clone_at)
          .with(repo_url, repo_root_directory)
          .and_return(repo)

        expect(GitRepository).to receive(:new).with(repo).and_return(git_repository)

        result = git_loader.get(:repo_name)

        expect(result).to eq(git_repository)
      end
    end

    context 'when the repo exists' do
      it '' do

      end
    end

    context 'when the repo exists and is out of date' do
      it '' do

      end
    end
  end
end
