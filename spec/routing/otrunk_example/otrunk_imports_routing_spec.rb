require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtrunkImportsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "otrunk_example_otrunk_imports", :action => "index").should == "/otrunk_example_otrunk_imports"
    end
  
    it "maps #new" do
      route_for(:controller => "otrunk_example_otrunk_imports", :action => "new").should == "/otrunk_example_otrunk_imports/new"
    end
  
    it "maps #show" do
      route_for(:controller => "otrunk_example_otrunk_imports", :action => "show", :id => "1").should == "/otrunk_example_otrunk_imports/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "otrunk_example_otrunk_imports", :action => "edit", :id => "1").should == "/otrunk_example_otrunk_imports/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "otrunk_example_otrunk_imports", :action => "create").should == {:path => "/otrunk_example_otrunk_imports", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "otrunk_example_otrunk_imports", :action => "update", :id => "1").should == {:path =>"/otrunk_example_otrunk_imports/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "otrunk_example_otrunk_imports", :action => "destroy", :id => "1").should == {:path =>"/otrunk_example_otrunk_imports/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/otrunk_example_otrunk_imports").should == {:controller => "otrunk_example_otrunk_imports", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/otrunk_example_otrunk_imports/new").should == {:controller => "otrunk_example_otrunk_imports", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/otrunk_example_otrunk_imports").should == {:controller => "otrunk_example_otrunk_imports", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/otrunk_example_otrunk_imports/1").should == {:controller => "otrunk_example_otrunk_imports", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/otrunk_example_otrunk_imports/1/edit").should == {:controller => "otrunk_example_otrunk_imports", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/otrunk_example_otrunk_imports/1").should == {:controller => "otrunk_example_otrunk_imports", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/otrunk_example_otrunk_imports/1").should == {:controller => "otrunk_example_otrunk_imports", :action => "destroy", :id => "1"}
    end
  end
end
