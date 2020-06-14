require File.expand_path('../../spec_helper', __FILE__)

describe DeepCloning do
  describe "Pages in a Section" do
    before(:each) do
      @page = Page.create!(:name => "Page", :description => "Page description")
      @page2 = Page.create!(:name => "Page2", :description => "Page2 description")
      @section = Section.create!(:name => "Section", :description => "Section description")
      @section.pages << @page
      @section.pages << @page2
      expect(@section.pages[0].name).to eq("Page")
      expect(@section.pages[1].name).to eq("Page2")
    end

    it "should keep the pages in the same order" do
      klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
      expect(klone.pages.size).to eq(2)
      expect(klone.pages[0].name).to eq("Page")
      expect(klone.pages[1].name).to eq("Page2")
    end

    it "should not modify the source when duplication fails" do
      # have page2 return an object that can't be saved
      bad_clone = Page.new(:name => "Bad Clone")
      allow(bad_clone).to receive(:save).and_return(false)
      allow(@page2).to receive(:dup).and_return(bad_clone)
      begin
        klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages 
      rescue ActiveRecord::RecordNotSaved
      end
      @section.reload
      expect(@section.pages.count).to eq(2)
    end
  end
end
