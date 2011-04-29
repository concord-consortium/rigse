require 'spec_helper'

describe Embeddable::Diy::SectionsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "embeddable/diy/sections" }.should route_to(:controller => "embeddable/diy/sections", :action => "index")
    end
  end
end
