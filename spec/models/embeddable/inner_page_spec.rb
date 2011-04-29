require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')



describe Embeddable::InnerPage do
  before(:each) do
    @page = Factory(:page)
    @sub_page = Page.create!
    @valid_attributes = {
      :name => "test innner page",
      :description => "this is the description for the inner page"
    }
    @inner_page = Embeddable::InnerPage.create!(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    @inner_page.should_not be_nil
  end
  
  it "should belong to a page" do
    @page.add_element @inner_page
    assert @inner_page.pages.include?(@page)
  end
  
  it "should contain many sub-pages" do
    @inner_page.sub_pages << @page
    @inner_page.save
    id = @inner_page.id
    
    # find it, and check:
    another_inner_page = Embeddable::InnerPage.find(id)
    assert another_inner_page.sub_pages.include?(@page)
  end

end
