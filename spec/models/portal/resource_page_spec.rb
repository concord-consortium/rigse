require 'spec_helper'

describe Portal::ResourcePage do
  
  describe "being created" do
    before do
      @resource_page = Portal::ResourcePage.new
    end
    
    it "should not be valid by default" do
      @resource_page.should_not be_valid
    end
    
    it "should require a user id and a title" do
      @resource_page.user_id = 1
      @resource_page.should_not be_valid
      
      @resource_page.title = "testing title"
      @resource_page.should be_valid
    end
    
    
  end
end