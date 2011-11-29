require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataTablesController do

  describe 'normal behavior' do
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
