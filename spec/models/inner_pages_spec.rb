require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class InnerPagePage
  def <(other)
    return (self.position < other.position)
  end
end

class InnerPage
  def is_contiguous
    last = nil
    self.inner_page_pages.each do |i| 
      if (last)
        return false unless last < i
      end
      last = i
    end
    true
  end

  def shuffle
    self.inner_page_pages.size.downto(1) { |n| self.inner_page_pages.push self.inner_page_pages.delete_at(rand(n)) }
  end

  def sort_by_name
    self.inner_page_pages.sort {|a,b| a.page.name <=> b.page.name}
  end

  def inspect
    self.inner_page_pages.each do |i| 
      puts "#{i.id} #{i.position} #{i.page.name}"
    end
  end
end

describe InnerPage do
  before(:each) do
    @page = Page.create!
    @sub_page = Page.create!
    @valid_attributes = {
      :name => "test innner page",
      :description => "this is the description for the inner page"
    }
    @inner_page = InnerPage.create!(@valid_attributes)
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
    another_inner_page = InnerPage.find(id)
    assert another_inner_page.sub_pages.include?(@page)
  end
  
  it "should be able to sort the sub-pages" do
    1.upto(10).each do |i|
      p = Page.create(:name => "page #{i}")
      p.save
      @inner_page.sub_pages << p
    end
    @inner_page.save
    @inner_page = InnerPage.find(@inner_page.id)
    assert @inner_page.is_contiguous
    
    @inner_page.shuffle
    @inner_page.inspect
    assert (!@inner_page.is_contiguous)
    @inner_page.save
    @inner_page = InnerPage.find(@inner_page.id)
    @inner_page.inspect
    assert (!@inner_page.is_contiguous)
    
    @inner_page.sort_by_name
    @inner_page.save
    @inner_page = InnerPage.find(@inner_page.id)
    @inner_page.inspect
    assert (@inner_page.is_contiguous)   
  end
  
  it "should have sub-pages that contain page elements" do
  end
  
  it "should throw an error if you try to add a inner-page to an inner-page" do
  end
  

end
