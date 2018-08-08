require File.expand_path('../../spec_helper', __FILE__)

describe PageElement do

  before(:each) do
    @page_element = Factory :page_element
    @user = Factory :user
  end
  
  it "should not be nil" do
    expect(@page_element).not_to be_nil
  end
  
  it "not original have an owner" do
    expect(@page_element.user).to be_nil
  end
  
  it "should let an onwer be assinged to it" do
    @page_element.user = @user
    expect(@page_element.user).to be(@user)
  end
  
  it "should persist its owner information" do
    @page_element.user = @user
    @page_element.save
    @page_element.reload
    expect(@page_element.user).not_to be_nil
    expect(@page_element.user).to eq(@user)
  end
  
  it "should be changable by its owner" do
    @page_element.user = @user
    expect(@page_element).to be_changeable(@user)
  end
  
end
