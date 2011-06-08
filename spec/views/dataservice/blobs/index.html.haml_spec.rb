require File.expand_path('../../../../spec_helper', __FILE__)

describe "/dataservice/blobs/index.html.haml" do
  include Dataservice::BlobsHelper

  before(:each) do
    # cut off the show_menu_for helper which traverses lots of other code
    template.stub!(:show_menu_for).and_return("show menu")

    # the changeable? => true prevents a current_user lookup, but will test if editing links correctly wrap the passed block
    collection = WillPaginate::Collection.create(1,10) do |coll|
      coll << stub_model(Dataservice::Blob, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", :content => "1", :changeable? => true)
      coll << stub_model(Dataservice::Blob, :id => 2, :token => "8ad04a50ba96463d80407cd119173b86", :content => "2", :changeable? => true)
      coll.total_entries = 2
    end
    assigns[:dataservice_blobs] = collection
  end

  it "renders a list of dataservice_blobs" do
    render
  end
end
