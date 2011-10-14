require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::BreedOffspringsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_breed_offspring
    assert_select('OTBreedOffspring') do
      assert_select('fatherOrganism') do
        assert_select('OTOrganism') do
          assert_select('world') do
            assert_select('OTWorld')
          end
        end
      end
      assert_select('motherOrganism') do
        assert_select('OTOrganism') do
          assert_select('world') do
            assert_select('OTWorld')
          end
        end
      end
    end
  end

end

# <OTBreedOffspring height='200' local_id='breed_offspring_231' width='400'>
#   <fatherOrganism>
#     <OTOrganism alleles='a:H,b:H' allowFatalCharacteristic='true' local_id='organism_762' name='Horned Male Dragon' sex='0' strain=''>
#       <world>
#         <OTWorld local_id='world_442' speciesPath='org/concord/biologica/worlds/dragon.xml'></OTWorld>
#       </world>
#     </OTOrganism>
#   </fatherOrganism>
#   <motherOrganism>
#     <OTOrganism alleles='a:W,b:W' allowFatalCharacteristic='true' local_id='organism_763' name='Female Winged Dragon' sex='1' strain=''>
#       <world>
#         <object refid='${world_442}'></object>
#       </world>
#     </OTOrganism>
#   </motherOrganism>
# </OTBreedOffspring>
