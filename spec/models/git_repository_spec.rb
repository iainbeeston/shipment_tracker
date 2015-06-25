require 'rails_helper'
require 'git_repository'
require 'support/git_test_repository'
require 'support/repository_builder'

require 'rugged'

RSpec.describe GitRepository do
  let(:test_git_repo) { Support::GitTestRepository.new }
  let(:rugged_repo) { Rugged::Repository.new(test_git_repo.dir) }
  subject(:repo) { GitRepository.new(rugged_repo) }

  describe '#exists?' do
    subject { repo.exists?(sha) }

    context 'when commit id exists' do
      let(:sha) { test_git_repo.create_commit.oid }
      it { is_expected.to be(true) }
    end

    context 'when commit id does not exist' do
      let(:sha) { '8056d10ec2776f5f2d6fe382560dc20a14fb565d' }
      it { is_expected.to be(false) }
    end

    context 'when commit id is too short (even if it exists)' do
      let(:sha) { test_git_repo.create_commit.oid.slice(1..3) }
      it { is_expected.to be(false) }
    end

    context 'when commit id is invalid' do
      let(:sha) { '1NV4LiD' }
      it { is_expected.to be(false) }
    end
  end

  describe '#commits_between' do
    let(:test_git_repo) { Support::RepositoryBuilder.build(git_diagram) }
    let(:git_diagram) { '-A-B-C-o' }

    it 'returns all commits between two commits' do
      commit_a = test_git_repo.commit_for_pretend_version('A')
      commit_b = test_git_repo.commit_for_pretend_version('B')
      commit_c = test_git_repo.commit_for_pretend_version('C')

      commits = repo.commits_between(commit_a, commit_c).map(&:id)

      expect(commits).to contain_exactly(commit_b, commit_c)
    end

    context 'when an invalid commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit
        invalid_commit_oid = '1NV4LiD'

        expect {
          repo.commits_between(valid_commit.oid, invalid_commit_oid)
        }.to raise_error(GitRepository::CommitNotValid, invalid_commit_oid)
      end
    end

    context 'when a non existent commit is provided' do
      it 'raises a GitRepository::CommitNotValid exception' do
        valid_commit = test_git_repo.create_commit
        non_existent_commit_oid = '8120765f3fce2da11a5c8e17d3ca800847912424'

        expect {
          repo.commits_between(valid_commit.oid, non_existent_commit_oid)
        }.to raise_error(GitRepository::CommitNotFound, non_existent_commit_oid)
      end
    end
  end

  describe '#recent_commits' do
    it 'returns specified number of recent commits' do
      test_git_repo.create_commit
      commit_second = test_git_repo.create_commit
      commit_third  = test_git_repo.create_commit
      commit_fourth = test_git_repo.create_commit

      commits = repo.recent_commits(3)

      expect(commits).to eq([
        build_commit(commit_fourth),
        build_commit(commit_third),
        build_commit(commit_second),
      ])
    end

    describe 'branch selection' do
      let(:sample_commit) { test_git_repo.create_commit }
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

  describe '#get_descendant_commits_of_branch' do
    context "when given commit is part of a branch that's merged into master" do
      it 'returns the descendant commits up to and including the merge commit' do
        test_git_repo.create_commit
        test_git_repo.create_branch('branch')
        test_git_repo.checkout_branch('branch')
        test_git_repo.create_commit
        branch_2 = test_git_repo.create_commit
        branch_3 = test_git_repo.create_commit
        test_git_repo.checkout_branch('master')
        test_git_repo.create_commit
        merge_commit = test_git_repo.merge_branch(branch_name: 'branch')
        test_git_repo.create_commit

        expect(repo.get_descendant_commits_of_branch(branch_2.oid)).to contain_exactly(
          build_commit(branch_3),
          build_commit(merge_commit),
        )
      end
    end

    context 'when given commit on master' do
      it 'returns empty' do
        test_git_repo.create_commit
        test_git_repo.checkout_branch('master')
        master_2 = test_git_repo.create_commit
        test_git_repo.create_commit

        expect(repo.get_descendant_commits_of_branch(master_2.oid)).to be_empty
      end

      context 'and it is the initial commit' do
        it 'returns empty' do
          master_1 = test_git_repo.create_commit
          test_git_repo.checkout_branch('master')
          test_git_repo.create_commit

          expect(repo.get_descendant_commits_of_branch(master_1.oid)).to be_empty
        end
      end
    end

    context 'when branch not merged' do
      it 'returns the descendant commits up to the tip of the branch' do
        test_git_repo.create_commit
        test_git_repo.create_branch('branch')
        test_git_repo.checkout_branch('branch')
        test_git_repo.create_commit
        branch_2 = test_git_repo.create_commit
        test_git_repo.create_commit
        test_git_repo.checkout_branch('master')
        test_git_repo.create_commit

        expect(repo.get_descendant_commits_of_branch(branch_2.oid)).to be_empty
      end
    end
  end

  describe '#get_dependent_commits' do
    it 'returns the ancestors of a commit up to the merge base' do
      test_git_repo.create_commit
      test_git_repo.create_branch('branch')
      test_git_repo.checkout_branch('branch')
      branch_1 = test_git_repo.create_commit
      branch_2 = test_git_repo.create_commit
      branch_3 = test_git_repo.create_commit
      test_git_repo.create_commit
      test_git_repo.checkout_branch('master')
      test_git_repo.create_commit
      test_git_repo.merge_branch(branch_name: 'branch')

      expect(repo.get_dependent_commits(branch_3.oid)).to contain_exactly(
        build_commit(branch_2),
        build_commit(branch_1),
      )
    end

    context 'when the commit is the parent of a merge commit' do
      it 'includes the merge commit in the result' do
        test_git_repo.create_commit
        test_git_repo.create_branch('branch')
        test_git_repo.checkout_branch('branch')
        branch_1 = test_git_repo.create_commit
        branch_2 = test_git_repo.create_commit
        test_git_repo.checkout_branch('master')
        test_git_repo.create_commit
        merge = test_git_repo.merge_branch(branch_name: 'branch')

        expect(repo.get_dependent_commits(branch_2.oid)).to contain_exactly(
          build_commit(branch_1),
          build_commit(merge),
        )
      end
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
