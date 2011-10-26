require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::VideoPlayersController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_video_player
    assert_select('OTText')
    assert_select('OTCompoundDoc') do
      assert_select('bodyText')
    end
  end

end
