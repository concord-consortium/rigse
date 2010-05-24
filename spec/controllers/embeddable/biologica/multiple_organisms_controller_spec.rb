require 'spec_helper'

describe Embeddable::Biologica::MultipleOrganismsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_multiple_organism
    with_tag('OTMultipleOrganism') do
      with_tag('organisms')
    end
  end

end

# <OTMultipleOrganism height='400' local_id='multiple_organism_150' width='400'>
#   <organisms>
#   </organisms>
# </OTMultipleOrganism>
