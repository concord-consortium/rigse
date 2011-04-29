require 'spec_helper'

describe "/dataservice/blobs/show.html.haml" do
  include Dataservice::BlobsHelper
  before(:each) do
    # cut off the show_menu_for helper which traverses lots of other code
    template.stub!(:show_menu_for).and_return("show menu")

    # :changeable? => true prevents a current_user lookup, but will test if editing links correctly wrap the passed block
    assigns[:dataservice_blob] = @dataservice_blob = stub_model(Dataservice::Blob, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", 
      :content => "", :changeable? => true)
  end

  it "renders attributes in <p>" do
    render
  end
end
