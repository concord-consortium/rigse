require 'spec_helper'

describe Embeddable::Biologica::PedigreesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_pedigree
    with_tag('OTPedigree') do
      with_tag('organisms')
    end
  end

end

# <OTPedigree crossoverEnabled='false' height='400' local_id='pedigree_50' maximumNumberChildren='8' minimumNumberChildren='3' organismImageSize='4' organismImagesVisible='true' resetButtonVisible='true' sexTextVisible='true' topControlsVisible='true' width='400'>
#   <organisms>
#   </organisms>
# </OTPedigree>
