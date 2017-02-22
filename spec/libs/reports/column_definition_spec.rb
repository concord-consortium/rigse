require File.expand_path('../../../spec_helper', __FILE__)#include ApplicationHelper

describe Reports::ColumnDefinition do
  require 'spreadsheet'

  describe '#initialize' do
    it 'defines default values' do
      column_defs = Reports::ColumnDefinition.new
      expect(column_defs.title).to eq('Title')
      expect(column_defs.width).to eq(12)
      expect(column_defs.left_border).to eq(:none)
      expect(column_defs.top_border).to eq(:none)
      expect(column_defs.right_border).to eq(:none)
      expect(column_defs.bottom_border).to eq(:none)
      expect(column_defs.col_index).to be_nil
    end

    it 'accepts arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => 'Here is a title', :width => 20 })
      expect(column_defs.title).to eq('Here is a title')
      expect(column_defs.width).to eq(20)
    end

    it 'accepts nil arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => nil, :width => 13 })
      expect(column_defs.title).to eq('Title')
      expect(column_defs.width).to eq(13)
    end
  end

  describe '#write_header' do
    it 'sets the headers of the argument sheet' do
      skip 'Create a mock sheet'
    end
  end
end