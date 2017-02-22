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

  describe "Tricky Page Element Relationships" do
    before(:each) do
      @world = Embeddable::Biologica::World.create!(:name => "world", :description => "world description", :species_path => "org/concord/biologica/worlds/dragon.xml")
      @org = Embeddable::Biologica::Organism.create!(:name => "organism", :description => "organism description", :sex => 0, :fatal_characteristics => true, :world => @world)
      @static_org = Embeddable::Biologica::StaticOrganism.create(:name => "static org", :description => "static org description", :organism => @org)
      @static_org2 = Embeddable::Biologica::StaticOrganism.create(:name => "static org2", :description => "static org2 description", :organism => @org)
      @page = Page.create!(:name => "Page", :description => "Page description")
      @page2 = Page.create!(:name => "Page2", :description => "Page2 description")
      @section = Section.create!(:name => "Section", :description => "Section description")
      @section.pages << @page
      @section.pages << @page2
      @static_org.pages << @page
      @static_org2.pages << @page2
    end
    
    def compare_equal(obj1, obj2, attrs = [])
      compare(obj1, obj2, true, attrs)
    end
    
    def compare_not_equal(obj1, obj2, attrs = [])
      compare(obj1, obj2, false, attrs)
    end
    
    def compare(obj1, obj2, equal, attrs)
      if attrs.size == 0
        # FIXME Compare all the attributes
      else
        attrs.each do |att|
          if equal
            expect(obj1.send(att)).to eq(obj2.send(att))
          else
            expect(obj1.send(att)).not_to eq(obj2.send(att))
          end
        end
      end
    end
  
    it "should recursively clone page elements" do
      klone = @page.deep_clone
      klone.save!
      compare_equal(klone, @page, [:name, :description])
      expect(klone.page_elements.size).to eq(1)
      expect(klone.page_elements[0].embeddable.class).to eq(Embeddable::Biologica::StaticOrganism)
      compare_equal(klone.page_elements[0].embeddable, @static_org, [:name, :description])
      expect(klone.page_elements[0].embeddable.organism).not_to eq(nil)
      expect(klone.page_elements[0].embeddable.organism.class).to eq(Embeddable::Biologica::Organism)
      compare_equal(klone.page_elements[0].embeddable.organism, @org, [:name, :description, :sex])
      expect(klone.page_elements[0].embeddable.organism.world).not_to eq(nil)
      expect(klone.page_elements[0].embeddable.organism.world.class).to eq(Embeddable::Biologica::World)
      compare_equal(klone.page_elements[0].embeddable.organism.world, @world, [:name, :description, :species_path])
    end
    
    it "should not clone uuid or timestamps" do
      klone = @page.deep_clone :never_clone => [:uuid, :created_at, :updated_at]
      klone.save!
      compare_not_equal(klone, @page, [:uuid, :created_at, :updated_at])
      compare_not_equal(klone.page_elements[0].embeddable, @static_org, [:uuid, :created_at, :updated_at])
      compare_not_equal(klone.page_elements[0].embeddable.organism, @org, [:uuid, :created_at, :updated_at])
      compare_not_equal(klone.page_elements[0].embeddable.organism.world, @world, [:uuid, :created_at, :updated_at])
    end
    
    it "should not make multiple organisms or worlds" do
      klone = @section.deep_clone :no_duplicates => true, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
      expect(klone.pages.size).to eq(2)
      expect(klone.pages[0].page_elements[0].embeddable.organism).to eq(klone.pages[1].page_elements[0].embeddable.organism)
      expect(klone.pages[0].page_elements[0].embeddable.organism.world).to eq(klone.pages[1].page_elements[0].embeddable.organism.world)
    end
    
    it "should make multiple organisms or worlds" do
      klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
      expect(klone.pages.size).to eq(2)
      expect(klone.pages[0].page_elements[0].embeddable.organism).not_to eq(klone.pages[1].page_elements[0].embeddable.organism)
      expect(klone.pages[0].page_elements[0].embeddable.organism.world).not_to eq(klone.pages[1].page_elements[0].embeddable.organism.world)
    end
  end

end
