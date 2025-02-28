require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/index.html.haml" do

  before(:each) do
    # TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "images"
    assigns[:images] = @images = FactoryBot.create_list(:image, 2)
    @user = double(
      :has_role?       => true
    )
    allow(view).to receive(:current_visitor).and_return(@user)
  end

  it "should render list of images without error" do
    render
  end
end
