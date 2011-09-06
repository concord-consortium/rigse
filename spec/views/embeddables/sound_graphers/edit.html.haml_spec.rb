require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/sound_graphers/edit.html.haml" do

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    template.stub!(:edit_menu_for).and_return("edit menu")
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
  end

  it "renders the edit form" do
    render
    response.should have_selector("input[type=text][name='embeddable_sound_grapher[name]'][value='#{@name}']")
    response.should have_selector("select[name='embeddable_sound_grapher[display_mode]']") do
      with_tag("option[value='#{@display_mode}']")
    end
    response.should have_selector("select[name='embeddable_sound_grapher[max_frequency]']") do
      with_tag("option[value='#{@max_frequency}']")
    end
    response.should have_selector("select[name='embeddable_sound_grapher[max_sample_time]']") do
      with_tag("option[value='#{@max_sample_time}']")
    end
    response.should have_selector("form[action=#{embeddable_sound_grapher_path(@sound_grapher)}][method=post]") do
    end
  end

end
