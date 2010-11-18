require 'spec_helper'

# matchers for acts_as_list
def be_before(expected)
  simple_matcher("be before") do |given,matcher|
    matcher.failure_message = "expected #{given.inspect} to be before #{expected.inspect}"
    matcher.negative_failure_message = "expected #{given.inspect} not to be before #{expected.inspect}"
    given.position < expected.position
  end
end

def be_after(expected)
  simple_matcher("be after") do |given,matcher|
    matcher.failure_message = "expected #{given.inspect} to be after #{expected.inspect}"
    matcher.negative_failure_message = "expected #{given.inspect} not to be after #{expected.inspect}"
    given.position > expected.position
  end
end


describe Investigation do
  before(:each) do
    @valid_attributes = {
      :name => "test investigation",
      :description => "new decription"
    }
  end

  it "should create a new instance given valid attributes" do
    Investigation.create!(@valid_attributes)
  end
  
  describe "should be publishable" do
    before(:each) do
      @investigation = Investigation.create!(@valid_attributes)
    end
    
    it "should not be public by default" do
      @investigation.published?.should be(false)
    end
    it "should be public if published" do
      @investigation.publish!
      @investigation.public?.should be(true)
    end
    
    it "should not be public if unpublished " do
      @investigation.publish!
      @investigation.public?.should be(true)
      @investigation.un_publish!
      @investigation.public?.should_not be(true)
    end
    
    it "should define a method for available_states" do
      @investigation.should respond_to(:available_states)
    end
  end
  
  describe "should be duplicateable" do
    before(:each) do
      @investigation = Investigation.create!(@valid_attributes)
      @user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    end
    
    it "should not allow teachers to duplicate" do
      [:member, :guest].each do |role|
        @user.roles.destroy_all
        @user.add_role(role.to_s)
        
        @investigation.duplicateable?(@user).should be_false
      end
    end
    
    it "should allow admins, managers, etc. to duplicate" do
      [:admin, :manager, :researcher, :author].each do |role|
        @user.roles.destroy_all
        @user.add_role(role.to_s)
        
        @investigation.duplicateable?(@user).should be_true
      end
    end
  end
  

  describe "search_list (searching for investigations)" do
    before(:all) do
      # Fake use of GSE's
      # TODO: Test search for projects not using GSE's!
      @enable_gses = APP_CONFIG[:use_gse]
      APP_CONFIG[:use_gse] = true
    end
    after(:all) do
      # Restore use of GSE's
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

      physics7  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @seven} )
      physics8  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @eight} )

      bio7      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @seven} )
      bio8      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @eight} )

      invs = [
        {
          :name                   => "grade 7 physics",
          :grade_span_expectation => physics7
        },
        {
          :name                   => "grade 8 physics",
          :grade_span_expectation => physics8
        },
        {
          :name                   => "grade 7 bio",
          :grade_span_expectation => bio7
        },
        {
          :name                   => "grade 8 bio",
          :grade_span_expectation => bio8
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
        draft = Factory.create(:investigation, inv)
        draft.name << " (draft) "
        draft.save
        @drafts << draft.reload
      end
      @public_non_gse = Factory.create(:investigation, :name => "published non-gse investigation");
      @public_non_gse.publish!
      @public_non_gse.save
      @public_non_gse.reload
      @draft_non_gse  = Factory.create(:investigation, :name => "draft non-gse investigation"); 
    end
    # search (including drafts):
    # search for drafts in grade 8                # two entries
    
    it "should find all grade 8 phsysics investigations, including drafts" do
      options = {
        :grade_span => @eight,
        :domain_id  => @physics.id,
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        inv.domain.should == @physics
        inv.grade_span.should == @eight
      end
    end

  
    it "should find all grade phsysics investigations, including drafts" do
      options = {
        :domain_id  => @physics.id,
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        inv.domain.should == @physics
      end
    end

    it "should find all public and draft investigations" do
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.should include(*@drafts)
      found.should include(*@published)
    end

    it "should find all public and draft NON-GSE investigations too" do
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.should include(@public_non_gse)
      found.should include(@draft_non_gse)
    end
    
    it "should find only published, in grade 8 physics domain" do
      options = {
        :grade_span => @eight,
        :domain_id  => @physics.id,
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      found.size.should == 1
      found.each do |inv|
        inv.should be_public
        inv.domain.should == @physics
        inv.grade_span.should == @eight
      end
    end

    it "should find only published in pysics domain" do
      options = {
        :domain_id  => @physics.id,
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      found.should_not include(*@drafts)
      found.each do |inv|
        inv.should be_public
        inv.domain.should == @physics
      end
    end
    
    it "should find all published investigations" do
      options = {
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      found.should include(*@published)
      found.should include(@public_non_gse)
      found.should_not include(*@drafts)
    end
  end 

  describe "investigation with activities" do
    before(:each) do
      @inv_attributes = {
        :name => "test investigation",
        :description => "new decription"
      }
      @investigation = Investigation.create(@inv_attributes)
    end

    # We might want to have one activity in the future. 
    it "should have no acitivities initially" do
      @investigation.should have(0).activities
    end

    it "should have one activitiy after it is added" do
      @investigation.activities << Factory(:activity)
      @investigation.should have(1).activities
    end

    it "the position of the first activity should be 1" do
      activity = Factory(:activity)
      @investigation.activities << activity
      @investigation.should have(1).activities
      @investigation.save
      activity.position.should_not be_nil
      activity.position.should eql 1
    end


    it "the position of the first activity should be 1" do
      activity_one = Factory(:activity) 
      activity_two = Factory(:activity)
      @investigation.activities << activity_one
      @investigation.activities << activity_two
      @investigation.should have(2).activities
      activity_one.position.should eql 1
      activity_two.position.should eql 2
    end

    it "the activities honor the acts_as_list methods" do
      activity_one = Factory(:activity) 
      activity_two = Factory(:activity)
      @investigation.activities << activity_one
      @investigation.activities << activity_two
      
      @investigation.reload
      @investigation.activities.should eql([activity_one, activity_two])

      activity_one.move_to_bottom
      @investigation.reload
      @investigation.activities.should eql([activity_two, activity_one])
      
      # must reload the other activity for updated position.
      activity_two.reload
      activity_two.should be_before(activity_one)
      activity_one.should be_after(activity_two)
      
      # more fragile, but worth checking:
      activity_one.position.should eql 2
      activity_two.position.should eql 1
    end

  end

  describe "finding reportables within an investigation" do
    before(:all) do
      @investigation = Factory(:investigation)
      @activity = Factory(:activity)
      @section = Factory(:section)
      @page = Factory(:page)
      @m_choice = Factory(:multiple_choice)
      @m_choice_b = Factory(:multiple_choice)
      @sub_page = Factory(:page)
      @sub_page.page_elements << Factory(:page_element, :embeddable => @m_choice)
      @inner_page = Factory(:inner_page)
      @inner_page.sub_pages << @sub_page
      @page.page_elements << Factory(:page_element, :embeddable => @inner_page)
      @page.page_elements << Factory(:page_element, :embeddable => @m_choice_b)
      @page.page_elements << Factory(:page_element, :embeddable => Factory(:xhtml))
      @section.pages << @page
      @activity.sections << @section
      @investigation.activities << @activity
    end

    it "should have 2 multiple choices" do
      @investigation.should have(2).reportable_elements
      @investigation.reportable_elements.each do |elm|
        elm[:embeddable].should be_a(Embeddable::MultipleChoice)
      end
    end

    it "should not have any xhtmls" do
      @investigation.reportable_elements.each do |elm|
      elm[:embeddable].should_not be_a(Embeddable::Xhtml)
      end
    end
  end

end


