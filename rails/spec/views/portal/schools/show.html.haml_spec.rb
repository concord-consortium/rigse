require 'spec_helper'

describe "/portal/schools/show.html.haml" do
  let(:school_params) {
    {
      name: 'Hogwarts School of Magic',
      description: 'alma mater of Harry Potter',
      zipcode: '01002'
    }
  }
  
  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    @school = stub_model(Portal::School, school_params)
    assign(:portal_school, @school)
  end

  it "renders a link to the school index page" do
    render
    expect(rendered).to have_link("List Schools")
  end

  it "renders key school attributes" do
    render
    expect(rendered).to match(/Hogwarts/)
    expect(rendered).to match(/Harry Potter/)
    expect(rendered).to match(/01002/)
  end
end
