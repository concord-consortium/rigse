# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::Country, type: :model do

  # TODO: auto-generated
  describe '.csv_filemame' do
    it 'csv_filemame' do
      result = described_class.csv_filemame

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.from_csv_file' do
    it 'from_csv_file' do
      result = described_class.from_csv_file

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.remap_keys' do
    it 'remap_keys' do
      in_hash = {}
      result = described_class.remap_keys(in_hash)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.field_name_map' do
    it 'field_name_map' do
      result = described_class.field_name_map

      expect(result).not_to be_nil
    end
  end

  describe '.from_hash' do
    it 'from_hash' do
      in_hash = {:name => "Utopia"}
      result = described_class.from_hash(in_hash)

      expect(result).not_to be_nil
    end
  end

  describe '.adjust_country_name' do
    it 'adjust_country_name' do
      name = 'US'
      name = name.gsub(/^US$/, "United States")

      expect(name).not_to be_nil
    end
  end

end
