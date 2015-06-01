require 'rails_helper'

require 'support/shared_examples/tickets_projection_examples'

RSpec.describe TicketsProjection do
  subject(:projection) { described_class.new }

  it_behaves_like 'a tickets projection'
end
