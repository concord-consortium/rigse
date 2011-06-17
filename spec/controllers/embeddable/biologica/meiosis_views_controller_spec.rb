require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::MeiosisViewsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_meiosis_view
    with_tag('OTSex') do
      with_tag('fatherOrganism') do
        with_tag('OTOrganism') do
          with_tag('world') do
            with_tag('OTWorld')
          end
        end
      end
      with_tag('motherOrganism') do
        with_tag('OTOrganism') do
          with_tag('world') do
            with_tag('OTWorld')
          end
        end
      end
    end
  end

end

# <OTSex alignment_control_visible='false' controlled_alignment_enabled='false' controlled_crossover_enabled='false' crossover_control_visible='false' height='400' local_id='meiosis_view_62' replay_button_enabled='true' width='400'>
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
# </OTSex>
