require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::PedigreesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_pedigree
    with_tag('OTPedigree') do
      with_tag('organisms')
    end
  end

  describe "update" do 
    before(:each) do
      @mock_pedigree = mock_model(Embeddable::Biologica::Pedigree,{
        :name => "pedigree",
        :id => 37,
        :organism_ids => [1,2],
        :maximum_number_children =>5, :top_controls_visible =>true, :crossover_enabled=>false, :reset_button_visible => true, 
        :sex_text_visible => false, 
        :minimum_number_children => 3,
        :organism_images_visible => 0,
        :height => 400, 
        :description => "<p>description ...</p>", 
        :organism_image_size =>0, 
        :width => 400 
      });
    end
    it "the should attempt to update the organism_ids array" do
        Embeddable::Biologica::Pedigree.should_receive(:find).with("37").and_return(@mock_pedigree)
        @mock_pedigree.should_receive(:update_attributes).with({"organism_ids"=>["796", "797"]})
        embeddable_biologica_pedigree = { "organism_ids" => ["796,797"] }
        parms = { "id" => "37", "embeddable_biologica_pedigree" => embeddable_biologica_pedigree }
        put :update, parms
    end
  end
end
# <OTPedigree crossoverEnabled='false' height='400' local_id='pedigree_50' maximumNumberChildren='8' minimumNumberChildren='3' organismImageSize='4' organismImagesVisible='true' resetButtonVisible='true' sexTextVisible='true' topControlsVisible='true' width='400'>
#   <organisms>
#   </organisms>
# </OTPedigree>
