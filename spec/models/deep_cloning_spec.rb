require File.expand_path('../../spec_helper', __FILE__)

describe DeepCloning do
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
          obj1.send(att).should == obj2.send(att)
        else
          obj1.send(att).should_not == obj2.send(att)
        end
      end
    end
  end

  it "should recursively clone page elements" do
    klone = @page.deep_clone
    klone.save!
    compare_equal(klone, @page, [:name, :description])
    klone.page_elements.size.should == 1
    klone.page_elements[0].embeddable.class.should == Embeddable::Biologica::StaticOrganism
    compare_equal(klone.page_elements[0].embeddable, @static_org, [:name, :description])
    klone.page_elements[0].embeddable.organism.should_not == nil
    klone.page_elements[0].embeddable.organism.class.should == Embeddable::Biologica::Organism
    compare_equal(klone.page_elements[0].embeddable.organism, @org, [:name, :description, :sex])
    klone.page_elements[0].embeddable.organism.world.should_not == nil
    klone.page_elements[0].embeddable.organism.world.class.should == Embeddable::Biologica::World
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
    klone.pages.size.should == 2
    klone.pages[0].page_elements[0].embeddable.organism.should == klone.pages[1].page_elements[0].embeddable.organism
    klone.pages[0].page_elements[0].embeddable.organism.world.should == klone.pages[1].page_elements[0].embeddable.organism.world
  end
  
  it "should make multiple organisms or worlds" do
    klone = @section.deep_clone :no_duplicates => false, :never_clone => [:uuid, :created_at, :updated_at], :include => :pages
    klone.pages.size.should == 2
    klone.pages[0].page_elements[0].embeddable.organism.should_not == klone.pages[1].page_elements[0].embeddable.organism
    klone.pages[0].page_elements[0].embeddable.organism.world.should_not == klone.pages[1].page_elements[0].embeddable.organism.world
  end

end
