# frozen_string_literal: false

require 'spec_helper'

RSpec.describe B64 do

  # TODO: auto-generated
  describe '.folding_encode' do
    it 'folding_encode' do
      result = described_class::B64.folding_encode('str')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.encode' do
    it 'encode' do
      result = described_class::B64.encode('str')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.decode' do
    it 'decode' do
      result = described_class::B64.decode('str')

      expect(result).not_to be_nil
    end
  end

end
