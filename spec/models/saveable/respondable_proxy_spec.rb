# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Saveable::RespondableProxy, type: :model do


  # TODO: auto-generated
  describe '#hash' do
    it 'hash' do
      respondable = User.new
      respondable_proxy = described_class.new(respondable)
      result = respondable_proxy.hash

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#eql?' do
    xit 'eql?' do
      respondable = User.new
      respondable_proxy = described_class.new(respondable)
      other = double('other')
      result = respondable_proxy.eql?(other)

      expect(result).not_to be_nil
    end
  end

end
