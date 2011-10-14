require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/sound_graphers/edit.html.haml" do

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    view.stub!(:edit_menu_for).and_return("edit menu")
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
    assert_select("input[type=text][name='embeddable_sound_grapher[name]'][value='#{@name}']")
    assert_select("select[name='embeddable_sound_grapher[display_mode]']") do
      assert_select("option[value='#{@display_mode}']")
    end
    assert_select("select[name='embeddable_sound_grapher[max_frequency]']") do
      assert_select("option[value='#{@max_frequency}']")
    end
    assert_select("select[name='embeddable_sound_grapher[max_sample_time]']") do
      assert_select("option[value='#{@max_sample_time}']")
    end
    assert_select("form[action=#{embeddable_sound_grapher_path(@sound_grapher)}][method=post]") do
    end
  end

end
