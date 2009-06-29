require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OtrunkExample::OtrunkViewEntriesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "index").should == "/otrunk_example/otrunk_view_entries"
    end
  
    it "maps #new" do
      route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "new").should == "/otrunk_example/otrunk_view_entries/new"
    end
  
    it "maps #show" do
      route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "show", :id => "1").should == "/otrunk_example/otrunk_view_entries/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "edit", :id => "1").should == "/otrunk_example/otrunk_view_entries/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "create").should == {:path => "/otrunk_example/otrunk_view_entries", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "update", :id => "1").should == {:path =>"/otrunk_example/otrunk_view_entries/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "otrunk_example/otrunk_view_entries", :action => "destroy", :id => "1").should == {:path =>"/otrunk_example/otrunk_view_entries/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/otrunk_example/otrunk_view_entries").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/otrunk_example/otrunk_view_entries/new").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/otrunk_example/otrunk_view_entries").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/otrunk_example/otrunk_view_entries/1").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/otrunk_example/otrunk_view_entries/1/edit").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/otrunk_example/otrunk_view_entries/1").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/otrunk_example/otrunk_view_entries/1").should == {:controller => "otrunk_example/otrunk_view_entries", :action => "destroy", :id => "1"}
    end
  end
end
