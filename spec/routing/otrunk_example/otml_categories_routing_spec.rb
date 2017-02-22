require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtmlCategoriesController do
  describe "routing" do
    it "recognizes and generates #index" do
      expect({ :get => "otrunk_example/otml_categories" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "otrunk_example/otml_categories/new" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "otrunk_example/otml_categories/1" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "otrunk_example/otml_categories/1/edit" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "otrunk_example/otml_categories" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "create") 
    end

    it "recognizes and generates #update" do
      expect({ :put => "otrunk_example/otml_categories/1" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "otrunk_example/otml_categories/1" }).to route_to(:controller => "otrunk_example/otml_categories", :action => "destroy", :id => "1") 
    end
  end
end
