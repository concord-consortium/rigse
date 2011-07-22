require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::WorldsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_world
    with_tag('OTWorld')
  end

end

# <OTWorld local_id="world_442" speciesPath="org/concord/biologica/worlds/dragon.xml"/>