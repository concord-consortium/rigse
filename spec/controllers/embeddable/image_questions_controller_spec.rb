require 'spec_helper'

describe Embeddable::ImageQuestionsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_image_question
    with_tag('OTQuestion') do
      with_tag('OTCompoundDoc') 
      with_tag('input') do
        with_tag('OTLabbookEntryChooser')
      end
    end
  end

end
