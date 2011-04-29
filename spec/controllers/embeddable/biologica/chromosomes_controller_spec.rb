require 'spec_helper'

describe Embeddable::Biologica::ChromosomesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_chromosome
    with_tag('OTChromosome') do
      with_tag('organism') do
        with_tag('OTOrganism') do
          with_tag('world') do
            with_tag('OTWorld')
          end
        end
      end
    end
  end

end

# <OTChromosome height='400' local_id='chromosome_64' width='400'>
#   <organism>
#     <OTOrganism alleles='a:H,b:H' allowFatalCharacteristic='true' local_id='organism_762' name='Horned Male Dragon' sex='0' strain=''>
#       <world>
#         <OTWorld local_id='world_442' speciesPath='org/concord/biologica/worlds/dragon.xml'></OTWorld>
#       </world>
#     </OTOrganism>
#   </organism>
# </OTChromosome>
