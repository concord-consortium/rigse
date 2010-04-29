require 'spec_helper'

describe Embeddable::MultipleChoicesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_a_multiple_choice
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
