require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::SoundGraphersController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_sound_grapher
    with_tag('OTSoundGrapherModel')
  end

end
