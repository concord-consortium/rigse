require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/open_responses/edit.html.haml" do

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:edit_menu_for).and_return("edit menu")
    allow(view).to receive(:current_visitor).and_return(power_user)
    assign(:open_response, @open_response = stub_model(Embeddable::OpenResponse,
      :new_record? => false, 
      :id => 1,
      :uuid => "uuid",
      :font_size=>12, :rows=>5, :description=>"", :columns=>32,
      :default_response=>"Tell us how you feel.",
      :name => "Open Response",
      :prompt => "Prompt",
      :user => power_user))
  end

  it "renders the edit form" do
    render
    expect(rendered).to have_selector("form[action='#{embeddable_open_response_path(@open_response)}'][method=post]")
  end
  it "should have a prompt tag" do
    render
    expect(rendered).to have_selector("textarea[name='embeddable_open_response[prompt]']")
  end
  it "should have a rows field" do
    render
    expect(rendered).to have_selector("input[name='embeddable_open_response[rows]']")
  end
  # No one has asked for these yet, but they are in the model:
  # it "should have a columns field" do
  #   render
  #   rendered.should have_selector("input[name='embeddable_open_response[columns]']")
  # end
  # it "should have a font_size field" do
  #   render
  #   rendered.should have_selector("input[name='embeddable_open_response[font_size]']")
  # end
end
