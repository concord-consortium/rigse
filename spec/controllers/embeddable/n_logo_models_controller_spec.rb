require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::NLogoModelsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_n_logo_model
    assert_select('OTNLogoModel')
  end

end
