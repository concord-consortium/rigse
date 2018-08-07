require File.expand_path('../../../spec_helper', __FILE__)#include ApplicationHelper

describe Reports::ColumnDefinition do

  describe '#initialize' do
    it 'defines default values' do
      column_defs = Reports::ColumnDefinition.new
      expect(column_defs.title).to eq('Title')
      expect(column_defs.col_index).to be_nil
    end

    it 'accepts arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => 'Here is a title' })
      expect(column_defs.title).to eq('Here is a title')
    end

    it 'accepts nil arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => nil })
      expect(column_defs.title).to eq('Title')
    end

    it 'ignores width argument (so we can re-add width support later)' do
      column_defs = Reports::ColumnDefinition.new({ :title => 'Here is a title', :width => 13 })
      expect(column_defs.title).to eq('Here is a title')
    end
  end

  describe '#write_header' do
    it 'sets the headers of the argument sheet' do
      skip 'Create a mock sheet'
    end
  end
end
