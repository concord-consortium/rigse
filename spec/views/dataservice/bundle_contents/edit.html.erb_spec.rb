require 'spec_helper'

describe "/dataservice_bundle_contents/edit.html.erb" do
  include Dataservice::BundleContentsHelper

  before(:each) do
    assigns[:bundle_content] = @bundle_content = stub_model(Dataservice::BundleContent,
      :new_record? => false,
      :id => 1,
      :bundle_logger_id => 1,
      :position => 1,
      :body => "value for body",
      :otml => "value for otml",
      :processed => false,
      :valid_xml => false,
      :empty => false,
      :uuid => "value for uuid"
    )
  end

  it "renders the edit bundle_content form" do
    render

    response.should have_tag("form[action=#{bundle_content_path(@bundle_content)}][method=post]") do
      with_tag('input#bundle_content_id[name=?]', "bundle_content[id]")
      with_tag('input#bundle_content_bundle_logger_id[name=?]', "bundle_content[bundle_logger_id]")
      with_tag('input#bundle_content_position[name=?]', "bundle_content[position]")
      with_tag('textarea#bundle_content_body[name=?]', "bundle_content[body]")
      with_tag('textarea#bundle_content_otml[name=?]', "bundle_content[otml]")
      with_tag('input#bundle_content_processed[name=?]', "bundle_content[processed]")
      with_tag('input#bundle_content_valid_xml[name=?]', "bundle_content[valid_xml]")
      with_tag('input#bundle_content_empty[name=?]', "bundle_content[empty]")
      with_tag('input#bundle_content_uuid[name=?]', "bundle_content[uuid]")
    end
  end
end
