require File.expand_path('../../spec_helper', __FILE__)

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
  
  it "should be destroy'able" do
    act = Activity.create!(@valid_attributes)
    act.destroy
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
  
  describe "search_list (searching for activities)" do
    before(:each) do
      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
      
      @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"), :schools => [@mock_school])
      @author_user = Factory.next(:author_user)
      
      Factory.create(:portal_clazz, :name => 'Physics_Class')
      @mathematics_investigation = Factory.create(:investigation, :name => 'biology_inv', :user => @author_user, :publication_status => 'published')

      @intersecting_lines = Factory.create(:activity, :name => 'intersecting_lines' ,:investigation_id => @mathematics_investigation.id, :user => @author_user, :publication_status => 'published')
      @parallel_lines = Factory.create(:activity, :name => 'parallel_lines' , :investigation_id => @mathematics_investigation.id, :user => @author_user, :publication_status => 'published')
      @graphs_and_lines = Factory.create(:activity, :name => 'graphs_and_lines' , :investigation_id => @mathematics_investigation.id, :user => @author_user, :publication_status => 'published')
      @set_theory = Factory.create(:activity, :name => 'set_theory' , :investigation_id => @mathematics_investigation.id, :user => @author_user, :publication_status => 'published')
      
    end
    it "should search all the 4 activities including drafts" do
      options = {
        :include_drafts => true
      }
      found = Activity.search_list(options)
      
      found.should include(@intersecting_lines)
      found.should include(@parallel_lines)
      found.should include(@graphs_and_lines)
      found.should include(@set_theory)
    end
    
    it "should find only published activities" do
      options = {
        :include_drafts => false
      }
      found = Activity.search_list(options)
      
      found.should include(@intersecting_lines)
      found.should include(@parallel_lines)
      found.should include(@graphs_and_lines)
    end
    it "should return the activties in the required sorted order " do
      options = {
        :include_drafts => true,
        :sorted_order => 'name ASC'
      }
      found = Activity.search_list(options)
      found[0] = @graphs_and_lines
      found[1] = @intersecting_lines
      found[2] = @parallel_lines
      found[3] = @set_theory
    end
  end
end
