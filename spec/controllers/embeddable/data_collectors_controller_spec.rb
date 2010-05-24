require 'spec_helper'

describe Embeddable::DataCollectorsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_data_collector
    with_tag('OTDataCollector') do
      with_tag('source') do
        with_tag('OTDataGraphable') do
          with_tag('dataProducer')
        end
      end
      with_tag('xDataAxis') do
        with_tag('OTDataAxis')
      end
      with_tag('yDataAxis') do
        with_tag('OTDataAxis')
      end
    end
  end

end
