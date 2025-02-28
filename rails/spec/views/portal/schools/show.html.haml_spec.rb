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
    # TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "portal/schools"
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
