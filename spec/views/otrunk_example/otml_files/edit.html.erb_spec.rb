require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_files/edit.html.erb" do
  include OtrunkExample::OtmlFilesHelper
  
  before(:each) do
    assigns[:otml_file] = @otml_file = stub_model(OtrunkExample::OtmlFile,
      :new_record? => false,
      :uuid => "value for uuid",
      :otml_category_id => 1,
      :name => "value for name",
      :path => "value for path",
      :content => "value for content"
    )
  end

  it "renders the edit otml_file form" do
    render
    
    response.should have_tag("form[action=#{otml_file_path(@otml_file)}][method=post]") do
      with_tag('input#otml_file_uuid[name=?]', "otml_file[uuid]")
      with_tag('input#otml_file_otml_category_id[name=?]', "otml_file[otml_category_id]")
      with_tag('input#otml_file_name[name=?]', "otml_file[name]")
      with_tag('input#otml_file_path[name=?]', "otml_file[path]")
      with_tag('textarea#otml_file_content[name=?]', "otml_file[content]")
    end
  end
end


