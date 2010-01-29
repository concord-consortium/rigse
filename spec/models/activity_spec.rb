require 'spec_helper'

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
  
  describe "should be publishable" do
    before(:each) do
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
  
  describe "should be taggable" do
    
    before (:each) do
      @activity = Activity.create!(@valid_attributes)
    end
    
    it "should allow the tagging of grade_levels" do
      @activity.grade_level_list = "1-3, 4-6, 7-9, 10-12"
      @activity.save
      @activity.reload
      @activity.grade_level_list.should include("1-3")
    end
    it "should allow the tagging of subject_areas" do
      @activity.subject_area_list = "Physics"
      @activity.save
      @activity.reload
      @activity.subject_area_list.should include("Physics")
    end
    
    it "shulld allow the tagging of units" do
      @activity.unit_list = "Heat and Temperature"
      @activity.save
      @activity.reload
      @activity.unit_list.should include("Heat and Temperature")
    end
    
    it "should allow free-form tags" do
      @activity.tag_list = "xxx,yyy,zzz,dog"
      @activity.save
      @activity.reload
      @activity.tag_list.should include("dog")
    end
    
    it "should allow searching by grade_level" do
      @activity.grade_level_list = "1-3"
      @activity.save
      found = Activity.tagged_with("1-3", :on => :grade_level)
      found.should have(1).activity
      found = Activity.tagged_with("1-6", :on => :grade_level)
      found.should have(0).activities
    end
    
    it "should allow searching by units" do
      @activity.unit_list = "Heat and Electricity"
      @activity.save
      found = Activity.tagged_with("Heat and Electricity", :on => :unit)
      found.should have(1).activity
      found = Activity.tagged_with("Heat and Water", :on => :unit)
      found.should have(0).activities
    end
    
    it "should allow searching by subject_area" do
      @activity.subject_area_list = "Math"
      @activity.save
      found = Activity.tagged_with("Math", :on => :subject_area)
      found.should have(1).activity
      found = Activity.tagged_with("Art", :on => :subject_area)
      found.should have(0).activities
    end
    
    it "should allow searching by tag" do
      @activity.tag_list = "probe"
      @activity.save
      found = Activity.tagged_with("probe")
      found.should have(1).activity
      found = Activity.tagged_with("model")
      found.should have(0).activities
    end
  end
  
  #
  # Kind of testing HasPedigree and 
  # 
  describe "A pedigree" do
    before (:each) do
      @a = Activity.create!(@valid_attributes)
      @a_a = Activity.create!(@valid_attributes)
      @a_b= Activity.create!(@valid_attributes)
      @a.descendants << @a_a
      @a.descendants << @a_b
      @a.reload
      @a_a.reload
      @a_b.reload
    end
    
    it "has ancestors" do
      @a.ancestor.should be_nil
      @a_a.ancestor.should be(@a)
      @a_b.ancestor.should be(@b)
    end
    
    end
    it "has descendants" do
      @a.descendants.should_have(2).items
    end    
    
end
