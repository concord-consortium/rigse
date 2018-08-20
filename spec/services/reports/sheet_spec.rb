# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::Sheet do

  # TODO: auto-generated
  describe '#row' do
    it 'row' do
      options = {}
      sheet = described_class.new(options)
      index = 1
      result = sheet.row(index)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#last_row_index' do
    it 'last_row_index' do
      options = {}
      sheet = described_class.new(options)
      result = sheet.last_row_index

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_to_book' do
    xit 'add_to_book' do
      options = {}
      sheet = described_class.new(options)
      book = double('book')
      result = sheet.add_to_book(book)

      expect(result).not_to be_nil
    end
  end

end
