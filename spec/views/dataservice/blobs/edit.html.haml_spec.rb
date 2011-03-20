require 'spec_helper'

describe "/dataservice/blobs/edit.html.haml" do
  include Dataservice::BlobsHelper

  before(:each) do
    # cut off the edit_menu_for helper which traverses lots of other code
    template.stub!(:edit_menu_for).and_return("edit menu")
    assigns[:dataservice_blob] = @dataservice_blob = stub_model(Dataservice::Blob,
      :new_record? => false, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", :content => ""
    )
  end

  it "renders the edit blob form" do
    render

    response.should have_tag("form[action=#{dataservice_blob_path(@dataservice_blob)}][method=post]") do
    end
  end
end
