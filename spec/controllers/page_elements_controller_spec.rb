require 'spec_helper'

describe  PageElementsController do
  before(:each) do
    generate_default_project_and_jnlps_with_mocks  
  end
  describe "routing" do

    it "recognizes and generates post destroy" do
      { :post   => "page_elements/1/destroy" }.should route_to(:controller => "page_elements", :action => "destroy", :id => "1")
      #TODO: renable default restful delete resource?
      #{ :delete => "page_elements/1" }.should route_to(:controller => "page_elements", :action => "destroy", :id => "1")
    end

    it "recognizes and generates post enable" do
      { :post => "page_elements/1/enable" }.should route_to(:controller => "page_elements", :action => "enable", :id => "1")
    end

    it "recognizes and generates post disable" do
      { :post => "page_elements/1/disable" }.should route_to(:controller => "page_elements", :action => "disable", :id => "1")
    end

  end

  describe "when the page element is owned by the current_user" do
    integrate_views
    before(:each) do
      @author = Factory.create(:user)
      @page_element = mock_model(PageElement)
      stub_current_user(@author)
      PageElement.stub(:find => @page_element)
      @page_element.should_receive(:changeable?).with(@author).and_return(true)
    end

    it "can be disabled by the current_user" do
      @page_element.should_receive(:is_enabled=).with(false)
      @page_element.should_receive(:save).and_return(true)
      post :disable, :id => "1"
    end
    it "can be enabled by the current user" do
      @page_element.should_receive(:is_enabled=).with(true)
      @page_element.should_receive(:save).and_return(true)
      post :enable, :id => "1"
    end
  end

  describe "when the page element is not owned by the current_user" do
    integrate_views
    before(:each) do
      @not_author = Factory.create(:user)
      @page_element = mock_model(PageElement)
      stub_current_user(@not_author)
      PageElement.stub(:find => @page_element)
      @page_element.should_receive(:changeable?).with(@not_author).and_return(false)
    end
    it "can't be disabled by the current_user" do
      @page_element.should_not_receive(:is_enabled=)
      @page_element.should_not_receive(:save)
      post :disable, :id => "1"
    end
    it "can't be enabled by the current user" do
      @page_element.should_not_receive(:is_enabled=)
      @page_element.should_not_receive(:save)
      post :enable, :id => "1"    end
  end

end
