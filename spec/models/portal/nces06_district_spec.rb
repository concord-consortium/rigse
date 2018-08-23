# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::Nces06District, type: :model do


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#capitalized_name' do
    it 'capitalized_name' do
      nces06_district = described_class.new('NAME' => 'a name')
      result = nces06_district.capitalized_name

      expect(result).not_to be_nil
    end
  end

end
