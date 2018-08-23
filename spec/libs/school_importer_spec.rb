# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe SchoolImporter do

  # TODO: auto-generated
  describe '.run' do
    it 'run' do
      result = described_class.run

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.title_case' do
    it 'title_case' do
      result = described_class.title_case

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#read_file' do
    it 'read_file' do
      school_importer = described_class.new
      result = school_importer.read_file

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parse_data' do
    it 'parse_data' do
      school_importer = described_class.new
      result = school_importer.parse_data

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_csv_row' do
    it 'add_csv_row' do
      school_importer = described_class.new
      line = double('line')
      result = school_importer.add_csv_row(line)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#log' do
    it 'log' do
      school_importer = described_class.new()
      message = double('message')
      opts = double('opts')
      result = school_importer.log(message, opts)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#district_for' do
    it 'district_for' do
      school_importer = described_class.new()
      row = double('row')
      result = school_importer.district_for(row)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_for' do
    it 'school_for' do
      school_importer = described_class.new()
      row = double('row')
      result = school_importer.school_for(row)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete_all_others!' do
    it 'delete_all_others!' do
      school_importer = described_class.new()
      result = school_importer.delete_all_others!

      expect(result).not_to be_nil
    end
  end

end
