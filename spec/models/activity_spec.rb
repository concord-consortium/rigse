require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Activity do
  before(:each) do
    @valid_attributes = {
      :name => "test activity",
      :description => "new decription"
    }
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(@valid_attributes)
  end
  
  
  ##
  ## TODO: Move to publishable_spec ?
  ##
  describe "should be publishable and" do
    before (:each) do
      @activity = Activity.create!(@valid_attributes)
    end
    
    it "should not be public by default" do
      @activity.published?.should be(false)
    end
    it "should be public if published" do
      @activity.publish!
      @activity.public?.should be(true)
    end
    
    it "should not be public if unpublished " do
      @activity.publish!
      @activity.public?.should be(true)
      @activity.un_publish!
      @activity.public?.should_not be(true)
    end
  end
  
  ##
  ## TODO: Move to taggable_spec ?
  ##
  describe "should be taggable and" do
    
    before (:each) do
      @activity = Activity.create!(@valid_attributes)
    end
    
    it "allow the tagging of grade_levels" do
      @activity.grade_level_list = "1-3, 4-6, 7-9, 10-12"
      @activity.save
      @activity.reload
      @activity.grade_level_list.should include("1-3")
    end
    it "allow the tagging of subject_areas" do
      @activity.subject_area_list = "Physics"
      @activity.save
      @activity.reload
      @activity.subject_area_list.should include("Physics")
    end
    
    it "allow the tagging of units" do
      @activity.unit_list = "Heat and Temperature"
      @activity.save
      @activity.reload
      @activity.unit_list.should include("Heat and Temperature")
    end
    
    it "allow free-form tags" do
      @activity.tag_list = "xxx,yyy,zzz,dog"
      @activity.save
      @activity.reload
      @activity.tag_list.should include("dog")
    end
    
    it "allow searching by grade_level" do
      @activity.grade_level_list = "1-3"
      @activity.save
      found = Activity.tagged_with("1-3", :on => :grade_levels)
      found.should have(1).activity
      found = Activity.tagged_with("1-6", :on => :grade_levels)
      found.should have(0).activities
    end
    
    it "allow searching by units" do
      @activity.unit_list = "Heat and Electricity"
      @activity.save
      found = Activity.tagged_with("Heat and Electricity", :on => :units)
      found.should have(1).activity
      found = Activity.tagged_with("Heat and Water", :on => :units)
      found.should have(0).activities
    end
    
    it "allow searching by subject_area" do
      @activity.subject_area_list = "Math"
      @activity.save
      found = Activity.tagged_with("Math", :on => :subject_areas)
      found.should have(1).activity
      found = Activity.tagged_with("Art", :on => :subject_areas)
      found.should have(0).activities
    end
    
    it "allow searching by tag" do
      @activity.tag_list = "probe"
      @activity.save
      found = Activity.tagged_with("probe")
      found.should have(1).activity
      found = Activity.tagged_with("model")
      found.should have(0).activities
    end
  end
  
  ##
  ## TODO: Move to has_pedigree_spec ?
  ##
  describe "has a pedigrees that" do
    before (:each) do
      @a     = Factory(:activity, {:name => "A"})
      @a_a   = Factory(:activity, {:name => "A_A"})
      @a_b   = Factory(:activity, {:name => "A_B"})
      @a_a_a = Factory(:activity, {:name => "A_A_A"})
      @a.descendants << @a_a
      @a.descendants << @a_b
      @a_a.descendants << @a_a_a
      @a.reload
      @a_a.reload
      @a_b.reload
      @a_a_a.reload
    end
    
    it "has ancestors" do
      @a.ancestor.should be_nil
      @a_a.ancestor.id.should equal(@a.id)
      @a_b.ancestor.id.should equal(@a.id)
      @a_a_a.ancestor.id.should equal(@a_a.id)
      @a_a_a.ancestor.id.should_not equal(@a.id)
    end
    
    it "has descendants" do
      @a.descendants.should have(2).items
      @a.descendants.should include(@a_b)
      @a.descendants.should include(@a_a)
      @a_a.descendants.should have(1).items
      @a_a.descendants.should include(@a_a_a)
      @a_a.descendants.should_not include(@a_b)
    end
    
    it "has a pedigree" do
      @a_a.pedigree.should include(@a)
      @a_b.pedigree.should include(@a)
      @a_a_a.pedigree.should include(@a)
      @a_a_a.pedigree.should include(@a_a)
      @a_a_a.pedigree.should_not include(@a_b)
    end
    
    it "has deep descendents" do
      @a.all_descendants.should include(@a_a_a)
      @a_b.all_descendants.should_not include(@a_a_a)
    end
  end
  
end
