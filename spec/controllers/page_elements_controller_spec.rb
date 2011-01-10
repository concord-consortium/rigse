require 'spec_helper'

describe  PageElementsController do
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
end
