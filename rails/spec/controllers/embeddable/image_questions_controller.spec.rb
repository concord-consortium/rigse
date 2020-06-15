require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::ImageQuestionsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_image_question
    assert_select('OTQuestion') do
      assert_select('OTCompoundDoc') 
      assert_select('input') do
        assert_select('OTLabbookEntryChooser')
      end
    end
  end

end
