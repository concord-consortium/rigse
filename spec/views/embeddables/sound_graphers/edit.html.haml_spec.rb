require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/sound_graphers/edit.html.haml" do

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    template.stub!(:edit_menu_for).and_return("edit menu")
    assigns[:sound_grapher] = @sound_grapher = stub_model(Embeddable::SoundGrapher,
      :new_record? => false, 
      :id => 1, 
      :name => "Sound Grapher", 
      :description => "Desc", 
      :max_frequency => Embeddable::SoundGrapher.valid_max_frequencies.first,
      :display_mode => Embeddable::SoundGrapher.valid_display_modes.first,
      :max_sample_time => Embeddable::SoundGrapher.valid_max_sample_times.first
    )
  end

  it "renders the edit form" do
    render
    response.should have_tag("input[type=text][name=max_frequency]")
    response.should have_tag("form[action=#{embeddable_sound_grapher_path(@sound_grapher)}][method=post]") do
    end
  end

end
