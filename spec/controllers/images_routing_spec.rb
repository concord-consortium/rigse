require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagesController do
  describe "routing" do
    it "should route #index" do
      expect(:get => "/images").to route_to("images#index")
    end

    it "should route #new" do
      expect(:get => "/images/new").to route_to("images#new")
    end

    it "should route #create" do
      expect(:get => "/images/create").to route_to("images#create")
    end

    it "should route #view" do
      expect(:get => "/images/1/view").to route_to("images#view", :id => "1", :method => :get)
    end

    it "should route #list_filter" do
      expect(:post => "/images/list/filter").to route_to("images#index", :method => :post)
    end

    it "should route #show" do
      expect(:get => "/images/1").to route_to("images#show", :id => "1")
    end

    it "should route #edit" do
      expect(:get => "/images/1/edit").to route_to("images#edit", :id => "1")
    end

    it "should route #destroy" do
      expect(:delete => "/images/1").to route_to("images#destroy", :id => "1")
    end

  end
end
