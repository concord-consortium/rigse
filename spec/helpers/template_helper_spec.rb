require 'spec_helper'

describe TemplateHelper do
  
  before :each do
    @section = stub_model(Section, :name => "Learning About Taxidermy")
    helper.extend Haml
    helper.extend Haml::Helpers 
    helper.send :init_haml_helpers
  end
  
  describe 'a basic template_container' do
    it 'should render with edit button' do
      container = helper.template_container_for(@section)
      container.should have_tag("a[class=?]", "template_edit_link")
    end
  end

  describe "edit button" do
    it "should not show if no_edit is true" do
     container = helper.template_container_for(@section, :no_edit => true)
     container.should_not have_tag("a[class=?]", "template_edit_link")
    end
  end
  
end
