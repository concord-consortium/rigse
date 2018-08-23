# frozen_string_literal: false

require 'spec_helper'

RSpec.describe NationalDistrictImporter do

  # TODO: auto-generated
  describe '#tick' do
    it 'tick' do
      national_district_importer = described_class.new
      count = 1
      interval = 1
      string = ('string')
      result = national_district_importer.tick(count, interval, string)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#_import_schools' do
    xit '_import_schools' do
      national_district_importer = described_class.new
      school_values = double('school_values')
      result = national_district_importer._import_schools(school_values)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#_import_districts' do
    xit '_import_districts' do
      national_district_importer = described_class.new
      district_values = double('district_values')
      result = national_district_importer._import_districts(district_values)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_districts' do
    it 'load_districts' do
      national_district_importer = described_class.new
      result = national_district_importer.load_districts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_schools' do
    it 'load_schools' do
      national_district_importer = described_class.new
      result = national_district_importer.load_schools

      expect(result).to be_nil
    end
  end

end
