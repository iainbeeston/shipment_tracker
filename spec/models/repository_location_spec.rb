require 'rails_helper'

RSpec.describe RepositoryLocation do
  describe '.from_github_notification' do
    let(:github_payload) {
      JSON.parse(<<-END)
        {
          "before": "abc123",
          "after": "def456",
          "repository": {
            "name": "repo",
            "full_name": "some/repo",
            "git_url": "git://github.com/some/repo.git",
            "ssh_url": "git@github.com:some/repo.git",
            "clone_url": "https://github.com/some/repo.git"
          }
        }
      END
    }

    before do
      RepositoryLocation.create(name: 'some_other_repo', uri: 'ssh://git@github.com/some/other-repo.git')
    end

    context 'when the RepositoryLocation has a regular URI' do
      before do
        RepositoryLocation.create(name: 'some_repo', uri: 'ssh://git@github.com/some/repo.git')
      end

      it 'updates remote_head for the correct RepositoryLocation' do
        RepositoryLocation.update_from_github_notification(github_payload)

        expect(RepositoryLocation.find_by_name('some_repo').remote_head).to eq('def456')
        expect(RepositoryLocation.find_by_name('some_other_repo').remote_head).to be(nil)
      end
    end

    context 'when the RepositoryLocation has an SCP-like URI' do
      before do
        RepositoryLocation.create(name: 'some_repo', uri: 'git@github.com:some/repo.git')
      end

      it 'updates remote_head for the correct RepositoryLocation' do
        RepositoryLocation.update_from_github_notification(github_payload)

        expect(RepositoryLocation.find_by_name('some_repo').remote_head).to eq('def456')
        expect(RepositoryLocation.find_by_name('some_other_repo').remote_head).to be(nil)
      end
    end

    context 'when no RepositoryLocation is found' do
      it 'fails silently' do
        expect { RepositoryLocation.update_from_github_notification(github_payload) }.to_not raise_error
      end
    end
    context 'when payload does not have a repository key' do
      let(:github_payload) {
        JSON.parse(<<-END)
          {
            "before": "abc123",
            "after": "def456"
          }
        END
      }
      it 'fails silently' do
        expect { RepositoryLocation.update_from_github_notification(github_payload) }.to_not raise_error
      end
    end
  end
end
