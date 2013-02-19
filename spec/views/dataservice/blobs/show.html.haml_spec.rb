require File.expand_path('../../../../spec_helper', __FILE__)

describe "/dataservice/blobs/show.html.haml" do
  include Dataservice::BlobsHelper
  before(:each) do
    # cut off the show_menu_for helper which traverses lots of other code
    view.stub!(:show_menu_for).and_return("show menu")

    power_user = stub_model(User, :has_role? => true)
    view.stub!(:current_visitor).and_return(power_user)

    # :changeable? => true prevents a current_visitor lookup, but will test if editing links correctly wrap the passed block
    @dataservice_blob = stub_model(Dataservice::Blob, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", 
      :content => "", :changeable? => true)
    assign(:dataservice_blob, @dataservice_blob)
  end

  it "renders attributes in <p>" do
    render
  end
end
