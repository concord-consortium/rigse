require 'spec_helper'

describe TemplateHelper do
  include TemplateHelper
  
  before :each do
    @section = stub_model(Section, :name => "Learning About Taxidermy")
    helper.extend Haml
    helper.extend Haml::Helpers 
    helper.send :init_haml_helpers
  end
  
  describe 'a basic template_container' do
    it 'should render with enable, disable and edit buttons' do
      container = helper.template_container_for(@section)
      container.should have_tag("div[class=?]", "buttons") do
        with_tag("div[class=?]", "template_disable_button")
        with_tag("div[class=?]", "template_enable_button")
        with_tag("div[class=?]", "template_edit_button")
      end
    end
  end

  describe "edit button" do
    it "should not show if no_edit is true" do
     container = helper.template_container_for(@section, :no_edit => true)
     container.should_not have_tag("div[class=?]", "template_edit_button")
    end
  end
  
end
