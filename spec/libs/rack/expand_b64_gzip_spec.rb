# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Rack::ExpandB64Gzip do

  # TODO: auto-generated
  describe '#call' do
    xit 'call' do
      app = double('app')
      expand_b64_gzip = described_class.new(app)
      env = {}
      result = expand_b64_gzip.call(env)

      expect(result).not_to be_nil
    end
  end

end
