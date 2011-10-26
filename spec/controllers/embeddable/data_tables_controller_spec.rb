require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataTablesController do

  describe 'normal behavior' do
    it_should_behave_like 'an embeddable controller'

    def with_tags_like_an_otml_data_table
      assert_select('OTDataTable') do
        assert_select('dataStore') do
          assert_select('channelDescriptions')
          assert_select('values')
        end
      end
    end
  end
end
