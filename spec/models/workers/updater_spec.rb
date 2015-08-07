require 'rails_helper'

RSpec.describe Workers::Updater do

  let(:repository_updater) { instance_double(Repositories::Updater) }

  it 'runs the repository updater' do
    expect(repository_updater).to receive(:run)
    Workers::Updater.new(repository_updater).run
  end

  it 'does not allow two repository updaters to run' do
    allow(repository_updater).to receive(:run).once

    10.times.map { Thread.new { Workers::Updater.new(repository_updater).run } }.map(&:join)
  end
end
