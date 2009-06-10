require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_files/show.html.erb" do
  include OtrunkExample::OtmlFilesHelper
  before(:each) do
    assigns[:otml_file] = @otml_file = stub_model(OtrunkExample::OtmlFile,
      :uuid => "value for uuid",
      :otml_category_id => 1,
      :name => "value for name",
      :path => "value for path",
      :content => "value for content"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ path/)
    response.should have_text(/value\ for\ content/)
  end
end

