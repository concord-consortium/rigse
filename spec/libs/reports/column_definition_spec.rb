require File.expand_path('../../../spec_helper', __FILE__)#include ApplicationHelper

describe Reports::ColumnDefinition do
  require 'spreadsheet'

  describe '#initialize' do
    it 'defines default values' do
      column_defs = Reports::ColumnDefinition.new
      column_defs.title.should == 'Title'
      column_defs.width.should == 12
      column_defs.left_border.should == :none
      column_defs.top_border.should == :none
      column_defs.right_border.should == :none
      column_defs.bottom_border.should == :none
      column_defs.col_index.should be_nil
    end

    it 'accepts arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => 'Here is a title', :width => 20 })
      column_defs.title.should == 'Here is a title'
      column_defs.width.should == 20
    end

    it 'accepts nil arguments' do
      column_defs = Reports::ColumnDefinition.new({ :title => nil, :width => 13 })
      column_defs.title.should == 'Title'
      column_defs.width.should == 13
    end
  end

  describe '#write_header' do
    it 'sets the headers of the argument sheet' do
      pending 'Create a mock sheet'
    end
  end
end