require 'spec_helper'

describe Embeddable::NLogoModelsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_a_n_logo_model
    with_tag('OTNLogoModel')
  end

end
