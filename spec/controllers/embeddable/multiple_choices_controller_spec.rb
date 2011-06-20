require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoicesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_multiple_choice
    with_tag('OTQuestion') do
      with_tag('prompt') do
        with_tag('OTCompoundDoc') do
          with_tag('bodyText')
        end
      end
      with_tag('input') do
        with_tag('OTChoice') do
          with_tag('choices')
        end
      end
    end
  end

end
