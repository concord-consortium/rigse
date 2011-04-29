require 'spec_helper'

describe Embeddable::DrawingToolsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_drawing_tool
    with_tag('OTDrawingTool2') do
      with_tag('stamps')
    end
  end

end
