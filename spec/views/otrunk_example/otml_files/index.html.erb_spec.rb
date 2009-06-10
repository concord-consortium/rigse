require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_files/index.html.erb" do
  include OtrunkExample::OtmlFilesHelper
  
  before(:each) do
    assigns[:otrunk_example_otml_files] = [
      stub_model(OtrunkExample::OtmlFile,
        :uuid => "value for uuid",
        :otml_category_id => 1,
        :name => "value for name",
        :path => "value for path",
        :content => "value for content"
      ),
      stub_model(OtrunkExample::OtmlFile,
        :uuid => "value for uuid",
        :otml_category_id => 1,
        :name => "value for name",
        :path => "value for path",
        :content => "value for content"
      )
    ]
  end

  it "renders a list of otrunk_example_otml_files" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for path".to_s, 2)
    response.should have_tag("tr>td", "value for content".to_s, 2)
  end
end

