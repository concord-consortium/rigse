require 'spec_helper'

describe Embeddable::DataTablesController do
  describe 'with a data collector' do
    it_should_behave_like 'an embeddable controller'

    def create_new_data_table
      @data_collector = Factory.create('data_collector')
      @data_table = Factory.create('data_table', :data_collector => @data_collector)
      return @data_table
    end

    def with_tags_like_an_otml_data_table
      with_tag('OTDataTable') do
        with_tag('dataStore') do
          with_tag('object')
        end
      end
    end
  end

  describe 'without a data collector' do
    it_should_behave_like 'an embeddable controller'

    def with_tags_like_an_otml_data_table
      with_tag('OTDataTable') do
        with_tag('dataStore') do
          with_tag('channelDescriptions')
          with_tag('values')
        end
      end
    end
  end
end
