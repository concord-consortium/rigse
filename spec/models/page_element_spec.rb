require 'spec_helper'

describe PageElement do

  before(:each) do
    @page_element = Factory :page_element
    @user = Factory :user
  end
  
  it "should not be nil" do
    @page_element.should_not be_nil
  end
  
  it "not original have an owner" do
    @page_element.user.should be_nil
  end
  
  it "should let an onwer be assinged to it" do
    @page_element.user = @user
    @page_element.user.should be(@user)
  end
  
  it "should persist its owner information" do
    @page_element.user = @user
    @page_element.save
    @page_element.reload
    @page_element.user.should_not be_nil
    @page_element.user.should == @user
  end
  
  it "should be changable by its owner" do
    @page_element.user = @user
    @page_element.should be_changeable(@user)
  end
  
end
