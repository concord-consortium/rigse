require 'spec_helper'

class ViewWithApplicationHelper < ActionView::Base
   include ApplicationHelper
   # When actually running in a view the controller's instance variables are 
   # mixed into the object that is self when rendering, but instances 
   # created from a class that just inherits from ActionView::Base don't have 
   # those instance variables (like @page_title) mixed in. So I add it by hand.
   attr_accessor :page_title   
end

describe ViewWithApplicationHelper do
  
  before(:each) do
    @view = ViewWithApplicationHelper.new
  end
  
  describe "title" do
    it "should set @page_title" do
      @view.title('hello').should be_nil
      @view.page_title.should eql('hello')
    end
    
    it "should output container if set" do
      @view.title('hello', :h2).should have_tag('h2', 'hello')
    end
  end
  
end