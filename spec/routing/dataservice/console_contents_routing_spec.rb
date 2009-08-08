require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Dataservice::ConsoleContentsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "dataservice_console_contents", :action => "index").should == "/dataservice_console_contents"
    end

    it "maps #new" do
      route_for(:controller => "dataservice_console_contents", :action => "new").should == "/dataservice_console_contents/new"
    end

    it "maps #show" do
      route_for(:controller => "dataservice_console_contents", :action => "show", :id => "1").should == "/dataservice_console_contents/1"
    end

    it "maps #edit" do
      route_for(:controller => "dataservice_console_contents", :action => "edit", :id => "1").should == "/dataservice_console_contents/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "dataservice_console_contents", :action => "create").should == {:path => "/dataservice_console_contents", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "dataservice_console_contents", :action => "update", :id => "1").should == {:path =>"/dataservice_console_contents/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "dataservice_console_contents", :action => "destroy", :id => "1").should == {:path =>"/dataservice_console_contents/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/dataservice_console_contents").should == {:controller => "dataservice_console_contents", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/dataservice_console_contents/new").should == {:controller => "dataservice_console_contents", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/dataservice_console_contents").should == {:controller => "dataservice_console_contents", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/dataservice_console_contents/1").should == {:controller => "dataservice_console_contents", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/dataservice_console_contents/1/edit").should == {:controller => "dataservice_console_contents", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/dataservice_console_contents/1").should == {:controller => "dataservice_console_contents", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/dataservice_console_contents/1").should == {:controller => "dataservice_console_contents", :action => "destroy", :id => "1"}
    end
  end
end
