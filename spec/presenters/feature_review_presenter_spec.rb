require 'rails_helper'

RSpec.describe FeatureReviewPresenter do
  let(:tickets) { [] }
  let(:builds) { {} }
  let(:deploys) { [] }
  let(:qa_submission) { nil }
  let(:uatest) { nil }

  let(:projection) {
    instance_double(
      FeatureReviewProjection,
      tickets: tickets,
      builds: builds,
      deploys: deploys,
      qa_submission: qa_submission,
      uatest: uatest,
      locked?: true,
    )
  }

  subject(:presenter) { FeatureReviewPresenter.new(projection) }

  it 'delegates #tickets, #builds, #deploys, #qa_submission and #locked? to the projection' do
    expect(presenter.tickets).to eq(projection.tickets)
    expect(presenter.builds).to eq(projection.builds)
    expect(presenter.deploys).to eq(projection.deploys)
    expect(presenter.qa_submission).to eq(projection.qa_submission)
    expect(presenter.uatest).to eq(projection.uatest)
    expect(presenter.locked?).to eq(projection.locked?)
  end

  describe '#build_status' do
    context 'when all builds pass' do
      let(:builds) do
        {
          'frontend' => Build.new(status: 'success'),
          'backend'  => Build.new(status: 'success'),
        }
      end

      it 'returns :success' do
        expect(presenter.build_status).to eq(:success)
      end

      context 'but some builds are missing' do
        let(:builds) do
          {
            'frontend' => Build.new(status: 'success'),
            'backend'  => Build.new,
          }
        end

        it 'returns nil' do
          expect(presenter.build_status).to eq(nil)
        end
      end
    end

    context 'when any of the builds fails' do
      let(:builds) do
        {
          'frontend' => Build.new(status: 'failed'),
          'backend'  => Build.new(status: 'success'),
        }
      end

      it 'returns :failure' do
        expect(presenter.build_status).to eq(:failure)
      end
    end

    context 'when there are no builds' do
      it 'returns nil' do
        expect(presenter.build_status).to be nil
      end
    end
  end

  describe '#deploy_status' do
    context 'when all deploys are correct' do
      let(:deploys) do
        [
          Deploy.new(correct: :yes),
        ]
      end

      it 'returns :success' do
        expect(presenter.deploy_status).to eq(:success)
      end
    end

    context 'when any deploy is not correct' do
      let(:deploys) do
        [
          Deploy.new(correct: :yes),
          Deploy.new(correct: :no),
        ]
      end

      it 'returns :failure' do
        expect(presenter.deploy_status).to eq(:failure)
      end
    end

    context 'when there are no deploys' do
      it 'returns nil' do
        expect(presenter.deploy_status).to be nil
      end
    end
  end

  describe '#qa_status' do
    context 'when QA submission is accepted' do
      let(:qa_submission) { QaSubmission.new(status: 'accepted') }

      it 'returns :success' do
        expect(presenter.qa_status).to eq(:success)
      end
    end

    context 'when QA submission is rejected' do
      let(:qa_submission) { QaSubmission.new(status: 'rejected') }

      it 'returns :failure' do
        expect(presenter.qa_status).to eq(:failure)
      end
    end

    context 'when QA submission is missing' do
      it 'returns nil' do
        expect(presenter.qa_status).to be nil
      end
    end
  end

  describe '#uatest_status' do
    context 'when User Acceptance Tests have passed' do
      let(:uatest) { Uatest.new(status: 'success') }

      it 'returns :success' do
        expect(presenter.uatest_status).to eq(:success)
      end
    end

    context 'when User Acceptance Tests have failed' do
      let(:uatest) { Uatest.new(status: 'failed') }

      it 'returns :failure' do
        expect(presenter.uatest_status).to eq(:failure)
      end
    end

    context 'when User Acceptance Tests are missing' do
      it 'returns nil' do
        expect(presenter.uatest_status).to be nil
      end
    end
  end

  describe '#summary_status' do
    context 'when status of deploys, builds, and QA submission are success' do
      let(:builds) { { 'frontend' => Build.new(status: 'success') } }
      let(:deploys) { [Deploy.new(correct: :yes)] }
      let(:qa_submission) { QaSubmission.new(status: 'accepted') }

      it 'returns :success' do
        expect(presenter.summary_status).to eq(:success)
      end
    end

    context 'when any status of deploys, builds, or QA submission is failed' do
      let(:builds) { { 'frontend' => Build.new(status: 'success') } }
      let(:deploys) { [Deploy.new(correct: :yes)] }
      let(:qa_submission) { QaSubmission.new(status: 'rejected') }

      it 'returns :failure' do
        expect(presenter.summary_status).to eq(:failure)
      end
    end

    context 'when no status is a failure but at least one is a warning' do
      let(:builds) { { 'frontend' => Build.new } }
      let(:deploys) { [Deploy.new(correct: :yes)] }
      let(:qa_submission) { QaSubmission.new(status: 'accepted') }

      it 'returns nil' do
        expect(presenter.summary_status).to be(nil)
      end
    end
  end
end
