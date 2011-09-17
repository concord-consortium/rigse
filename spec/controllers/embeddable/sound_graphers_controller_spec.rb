require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::SoundGraphersController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_sound_grapher
    assert_select('OTSoundGrapherModel')
  end

  describe "render appropriate otml for a soundgraph" do
    render_views 
    
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      @display_mode = Embeddable::SoundGrapher.valid_display_modes.first
      @max_frequency = Embeddable::SoundGrapher.valid_max_frequencies.first
      @max_sample_time = Embeddable::SoundGrapher.valid_max_sample_times.first
      @name = "Sample Sound grapher"
      
      assigns[:sound_grapher] = @sound_grapher = stub_model(Embeddable::SoundGrapher,
        :new_record? => false, 
        :id => 1, 
        :name => @name, 
        :description => "Desc", 
        :display_mode => @display_mode,
        :max_frequency => @max_frequency,
        :max_sample_time => @max_sample_time
      )
      Embeddable::SoundGrapher.stub!(:find).and_return(@sound_grapher)
    end

    # %OTSoundGrapherModel{ 
    # :local_id => ot_local_id_for(sound_grapher), 
    # :displayMode => sound_grapher.display_mode, 
    # :maxFrequency => sound_grapher.max_frequency
    # :maxSampleTime => sound_grapher.max_sample_time 
    it "renders the otml view" do
      get :show, :id => "37", :format => 'otml'
      response.should render_template(:show)
      assert_select("OTSoundGrapherModel[displayMode='#{@display_mode}'][maxFrequency='#{@max_frequency}'][maxSampleTime='#{@max_sample_time}']")
    end
  end
end
