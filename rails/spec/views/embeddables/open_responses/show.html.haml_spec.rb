require File.expand_path('../../../../spec_helper', __FILE__)

describe "/embeddable/open_responses/show.html.haml" do

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

  it "should have a rows field" do
    render
    expect(rendered).to have_selector("textarea[rows='#{@open_response.rows.to_s}']")
  end
  it "should have a columns field" do
    render
    expect(rendered).to have_selector("textarea[cols='#{@open_response.columns.to_s}']")
  end
end
