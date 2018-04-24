require File.expand_path('../../spec_helper', __FILE__)

describe DeepCloning do
  describe "Pages in a Section" do
    before(:each) do
      @page = Page.create!(:name => "Page", :description => "Page description")
      @page2 = Page.create!(:name => "Page2", :description => "Page2 description")
      @section = Section.create!(:name => "Section", :description => "Section description")
      @section.pages << @page
      @section.pages << @page2
      @section.pages[0].name.should == "Page"
      @section.pages[1].name.should == "Page2"
    end

    it "should keep the pages in the same order" do
      klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
      klone.pages.size.should == 2
      klone.pages[0].name.should == "Page"
      klone.pages[1].name.should == "Page2"
    end

    it "should not modify the source when duplication fails" do
      # have page2 return an object that can't be saved
      bad_clone = Page.new(:name => "Bad Clone")
      bad_clone.stub(:save).and_return(false)
      @page2.stub(:dup).and_return(bad_clone)
      begin
        klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages 
      rescue ActiveRecord::RecordNotSaved
      end
      @section.reload
      @section.pages.count.should == 2
    end
  end
end
