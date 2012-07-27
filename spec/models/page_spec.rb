require File.expand_path('../../spec_helper', __FILE__)

describe Page do
  before(:each) do
    @valid_attributes = {
      :name => "first page",
      :description => "a description of the first page",
      :teacher_only => false
    }
  end

  it "should create a new instance given valid attributes" do
    Page.create!(@valid_attributes)
  end

  # at one point page had a default value set for :position
  # but that messes up acts_as_list
  describe "ordering" do
    it "should put pages in order by creation time" do
      @page = Page.create!(:name => "Page", :description => "Page description")
      @page2 = Page.create!(:name => "Page2", :description => "Page2 description")
      @page.reload
      @page2.reload
      @page.position.should == 1
      @page2.position.should == 2
    end
  end
end
