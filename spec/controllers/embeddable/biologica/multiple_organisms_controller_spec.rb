require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::MultipleOrganismsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_multiple_organism
    assert_select('OTMultipleOrganism') do
      assert_select('organisms')
    end
  end

end

# <OTMultipleOrganism height='400' local_id='multiple_organism_150' width='400'>
#   <organisms>
#   </organisms>
# </OTMultipleOrganism>
