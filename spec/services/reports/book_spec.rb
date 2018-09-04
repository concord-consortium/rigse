# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::Book do

  # TODO: auto-generated
  describe '#create_worksheet' do
    it 'create_worksheet' do
      options = {}
      book = described_class.new(options)
      _options = {}
      result = book.create_worksheet(_options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#to_axlsx_package' do
    it 'to_axlsx_package' do
      options = {}
      book = described_class.new(options)
      result = book.to_axlsx_package

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#to_data_string' do
    it 'to_data_string' do
      options = {}
      book = described_class.new(options)
      result = book.to_data_string

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save' do
    xit 'save' do
      options = {}
      book = described_class.new(options)
      filename = 'filename'
      result = book.save(filename)

      expect(result).not_to be_nil
    end
  end

end
