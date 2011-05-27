require 'spec_helper'

describe "/embeddable/open_responses/show.html.haml" do

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:edit_menu_for).and_return("edit menu")
    template.stub!(:current_user).and_return(power_user)
    assigns[:open_response] = @open_response = stub_model(Embeddable::OpenResponse,
      :new_record? => false, 
      :id => 1,
      :uuid => "uuid",
      :font_size=>12, :rows=>5, :description=>"", :columns=>32,
      :default_response=>"Tell us how you feel.",
      :name => "Open Response",
      :prompt => "Prompt",
      :user => power_user)
  end

  it "should have a rows field" do
    render
    response.should have_tag("textarea[rows=?]", @open_response.rows)
  end
  it "should have a columns field" do
    render
    response.should have_tag("textarea[cols=?]", @open_response.columns)
  end
end
