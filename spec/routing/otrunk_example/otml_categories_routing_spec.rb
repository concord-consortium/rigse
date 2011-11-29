require File.expand_path('../../../spec_helper', __FILE__)

describe  OtrunkExample::OtmlCategoriesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "otrunk_example/otml_categories" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "otrunk_example/otml_categories/new" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "otrunk_example/otml_categories/1" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "otrunk_example/otml_categories/1/edit" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "otrunk_example/otml_categories" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "otrunk_example/otml_categories/1" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "otrunk_example/otml_categories/1" }.should route_to(:controller => "otrunk_example/otml_categories", :action => "destroy", :id => "1") 
    end
  end
end
