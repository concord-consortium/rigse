# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe NcesParser do

  # TODO: auto-generated
  describe '#create_tables_migration' do
    xit 'create_tables_migration' do
      district_layout_file = double('district_layout_file')
      school_layout_file = double('school_layout_file')
      year = double('year')
      states_and_provinces = double('states_and_provinces')
      nces_parser = described_class.new(district_layout_file, school_layout_file, year, states_and_provinces)
      result = nces_parser.create_tables_migration

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#create_indexes_migration' do
    it 'create_indexes_migration' do
      district_layout_file = double('district_layout_file')
      school_layout_file = double('school_layout_file')
      year = double('year')
      states_and_provinces = double('states_and_provinces')
      nces_parser = described_class.new(district_layout_file, school_layout_file, year, states_and_provinces)
      result = nces_parser.create_indexes_migration

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_db' do
    it 'load_db' do
      district_layout_file = double('district_layout_file')
      school_layout_file = double('school_layout_file')
      year = double('year')
      states_and_provinces = double('states_and_provinces')
      nces_parser = described_class.new(district_layout_file, school_layout_file, year, states_and_provinces)
      district_data_files = double('district_data_files')
      school_data_files = double('school_data_files')
      result = nces_parser.load_db(district_data_files, school_data_files)

      expect(result).not_to be_nil
    end
  end

end
