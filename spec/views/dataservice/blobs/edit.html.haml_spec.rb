require File.expand_path('../../../../spec_helper', __FILE__)

describe "/dataservice/blobs/edit.html.haml" do
  include Dataservice::BlobsHelper

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    view.stub!(:edit_menu_for).and_return("edit menu")
    assign(:dataservice_blob, @dataservice_blob = stub_model(Dataservice::Blob,
      :new_record? => false, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", :content => ""
    ))
  end

  it "renders the edit blob form" do
    render

    rendered.should have_selector("form[action='#{dataservice_blob_path(@dataservice_blob)}'][method=post]") do
    end
  end
end
