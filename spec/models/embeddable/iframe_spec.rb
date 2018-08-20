# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Embeddable::Iframe, type: :model do


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigations' do
    it 'investigations' do
      iframe = described_class.new
      result = iframe.investigations

      expect(result).not_to be_nil
    end
  end

end
