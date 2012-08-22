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

  describe "search_list (searching for activity)" do
    before(:all) do
      @enable_gses = APP_CONFIG[:use_gse]
      APP_CONFIG[:use_gse] = true
    end
    after(:all) do
      APP_CONFIG[:use_gse] = @enable_gses
    end

    before(:each) do
      @bio = Factory.create( :rigse_domain,            { :name => "biology" } )
      bio_ks = Factory.create( :rigse_knowledge_statement, { :domain => @bio     } )
      bio_at = Factory.create( :rigse_assessment_target,       { :knowledge_statement => bio_ks })
      
      @physics = Factory.create( :rigse_domain,            { :name => "physics"  } )
      physics_ks = Factory.create( :rigse_knowledge_statement, { :domain => @physics  } )
      physics_at = Factory.create( :rigse_assessment_target,       { :knowledge_statement => physics_ks })
      
      @seven = "7"
      @eight = "8"

      physics_gse_grade7  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @seven} )
      physics_gse_grade8  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @eight} )

      bio_gse_grade7      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @seven} )
      bio_gse_grade8      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @eight} )

      invs = [
        {
          :name                   => "grade 7 physics",
          :grade_span_expectation => physics_gse_grade7
        },
        {
          :name                   => "grade 8 physics",
          :grade_span_expectation => physics_gse_grade8
        },
        {
          :name                   => "grade 7 bio",
          :grade_span_expectation => bio_gse_grade7
        },
        {
          :name                   => "grade 8 bio",
          :grade_span_expectation => bio_gse_grade8
        },
      ]
      @published = []
      @drafts = []
      invs.each do |inv|
        published = Factory.create(:investigation, inv)
        published.name << " (published) "
        published.publish!
        published.save
        @published << published.reload
        published_activity = Factory.create(:activity, :name => "activity for #{published.name}" ,:investigation_id => published.id)
        draft = Factory.create(:investigation, inv)
        draft.name << " (draft) "
        draft.save
        @drafts << draft.reload
        drafts_activity = Factory.create(:activity, :name => "activity for #{draft.name}" ,:investigation_id => draft.id)
      end
      @public_non_gse = Factory.create(:investigation, :name => "published non-gse investigation");
      @public_non_gse.publish!
      @public_non_gse.save
      @public_non_gse.reload
      @public_non_gse_activity = Factory.create(:activity, :name => "activity for #{@public_non_gse.name}" ,:investigation_id => @public_non_gse.id)
      @draft_non_gse  = Factory.create(:investigation, :name => "draft non-gse investigation"); 
      @draft_non_gse_activity = Factory.create(:activity, :name => "activity for #{@draft_non_gse.name}" ,:investigation_id => @draft_non_gse.id)
    
    #creating probe activities
      investigation = Investigation.find_by_name_and_publication_status('grade 7 physics', 'published')
      @probe_activity_published = Factory.create(:activity, :name => 'probe_activity(published)')
      @probe_activity_published.investigation = investigation
      @probe_activity_published.save!
      
      section = Factory.create(:section)
      section.activity = @probe_activity_published
      section.save!
      
      page = Factory.create(:page)
      page.section = section
      page.save!
      
      page_element = PageElement.new
      page_element.id = 1
      page_element.page = page
      page_element.embeddable_type = 'Embeddable::DataCollector'
      page_element.save!
      
      embeddable_data_collectors = Factory.create(:data_collector)
      
      page_element.embeddable = embeddable_data_collectors
      page_element.save!
      
      @probe_type = Factory.create(:probe_type)
      embeddable_data_collectors.probe_type = @probe_type
      embeddable_data_collectors.save!
    end
    # search (including drafts):
    # search for drafts in grade 8                # two entries
    
    it "should find all grade 8 physics activities, including draft activities" do
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Activity.search_list(options)
      found.each do |act|
        act.investigation.domain.should == @physics
        act.investigation.grade_span.should == @eight
      end
    end
    
    
    it "should find all grade physics activities, including drafts" do
      options = {
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Activity.search_list(options)
      found.each do |act|
        act.investigation.domain.should == @physics
      end
    end
    
    it "should find all public and draft activities" do
      options = {
        :include_drafts => true
      }
      found = Activity.search_list(options)
      @drafts.each do |inv|
        found.should include(inv.activities[0])
      end
      @published.each do |inv|
        found.should include(inv.activities[0])
      end
    end

    it "should find all public and draft NON-GSE activities too" do
      options = {
        :include_drafts => true
      }
      found = Activity.search_list(options)
      found.should include(@public_non_gse_activity)
      found.should include(@draft_non_gse_activity)
    end
    
    it "should find only published activities, in grade 8 physics domain" do
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
        :include_drafts => false
      }
      found = Activity.search_list(options)
      found.size.should == 1
      found.each do |act|
        act.investigation.should be_public
        act.investigation.domain.should == @physics
        act.investigation.grade_span.should == @eight
      end
    end

    it "should find only published activities in pysics domain" do
      options = {
        :domain_id  => [@physics.id],
        :include_drafts => false
      }
      found = Activity.search_list(options)
      @drafts.each do |inv|
        found.should_not include(inv.activities[0])
      end
      found.each do |act|
        act.investigation.should be_public
        act.investigation.domain.should == @physics
      end
    end
    
    it "should find all published activities" do
      options = {
        :include_drafts => false
      }
      found = Activity.search_list(options)
      @published.each do |inv|
        found.should include(inv.activities[0])
      end
      @drafts.each do |inv|
        found.should_not include(inv.activities[0])
      end
      found.should include(@public_non_gse_activity)
    end
    it "should search activities that require probes" do
      options = {
        :include_drafts => false,
        :probe_type => [@probe_type.id]
      }
      found = Activity.search_list(options)
      assert_equal found.length, 1
      found.should include(@probe_activity_published)
    end
    it "should search activities that does not require probes" do
      options = {
        :include_drafts => false,
        :probe_type => ['0']
      }
      found = Activity.search_list(options)
      found.should_not include(@probe_activity_published)
    end
  end 
end
