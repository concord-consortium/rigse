require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_schools/edit.html.erb" do
  include Portal::SchoolsHelper

  before(:each) do
    assigns[:school] = @school = stub_model(Portal::School,
      :new_record? => false,
      :district_id => 1,
      :nces_school_id => 1,
      :name => "value for name",
      :description => "value for description",
      :uuid => "value for uuid"
    )
  end

  it "renders the edit school form" do
    render

    response.should have_tag("form[action=#{school_path(@school)}][method=post]") do
      with_tag('input#school_district_id[name=?]', "school[district_id]")
      with_tag('input#school_nces_school_id[name=?]', "school[nces_school_id]")
      with_tag('input#school_name[name=?]', "school[name]")
      with_tag('textarea#school_description[name=?]', "school[description]")
      with_tag('input#school_uuid[name=?]', "school[uuid]")
    end
  end
end
