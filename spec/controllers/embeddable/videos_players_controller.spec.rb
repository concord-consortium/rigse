require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::VideoPlayersController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_video_player
    with_tag('OTText')
    with_tag('OTCompoundDoc') do
      with_tag('bodyText')
    end
  end

end
