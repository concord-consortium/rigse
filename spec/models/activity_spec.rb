require 'spec_helper'

describe Activity do
  before(:each) do
    @valid_attributes = {
      :name => "test activity",
      :description => "new decription"
    }
    @missing_description = {
      :name => "test activity"
    }
    @missing_name = {
      :description => "new decription"
    }
  end

  describe "create" do
    describe "validations" do
      it "should create a new instance given valid attributes" do
        Activity.create!(@valid_attributes)
      end
      
      describe "when unique names are required" do
        before(:each) do
          Admin::Project.stub!(:unique_activity_names).and_return(true)
        end
        it "it should be valid when it has a unique name" do
          act_a = Activity.create(@valid_attributes)
          act_a.should be_valid
        end
        it "it shouldn't be valid when the name is not unique" do
          act_a = Activity.create(@valid_attributes)
          act_a.should be_valid
          act_b = Activity.create(@valid_attributes)
          act_b.should_not be_valid
          act_b.errors[:name].should_not be_nil
        end
      end
      

      describe "when descriptions are required" do
        before(:each) do
          Admin::Project.stub!(:require_activity_descriptions).and_return(true)
        end
        it "should be invalid when the descritpion is missing" do
          act_a = Activity.create(@missing_description)
          act_a.should_not be_valid
          act_a.errors[:description].should  == Activity::MUST_HAVE_DESCRIPTION
        end
        it "should be valid when the descritpion is present" do
          act_a = Activity.create(@valid_attributes)
          act_a.should be_valid
        end
      end
    end
  end
  
  
  ##
  ## TODO: Move to publishable_spec ?
  ##
  describe "publication rules" do
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
  describe "tagging rules" do
    
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
