require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DrawingToolsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_drawing_tool
    assert_select('OTDrawingTool2') do
      assert_select('stamps')
    end
  end

end
