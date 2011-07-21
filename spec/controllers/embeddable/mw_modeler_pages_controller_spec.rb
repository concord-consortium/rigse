require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MwModelerPagesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_mw_modeler_page
    with_tag('OTModelerPage')
  end

end
