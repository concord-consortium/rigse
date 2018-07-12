require File.expand_path('../../spec_helper', __FILE__)

# matchers for acts_as_list

RSpec::Matchers.define :be_before do |expected|
  match                          { |given| given.position < expected.position }
  failure_message_for_should     { |given| "expected #{given.inspect} to be before #{expected.inspect}" }
  failure_message_for_should_not { |given| "expected #{given.inspect} not to be before #{expected.inspect}" }
  description                    { "be before #{expected.position}" }
end

RSpec::Matchers.define :be_after do |expected|
  match                          { |given| given.position > expected.position }
  failure_message_for_should     { |given| "expected #{given.inspect} to be after #{expected.inspect}" }
  failure_message_for_should_not { |given| "expected #{given.inspect} not to be after #{expected.inspect}" }
  description                    { "be after #{expected.position}" }
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
  
  it 'has_many for all BASE_EMBEDDABLES' do
    BASE_EMBEDDABLES.length.should be > 0
    @investigation = Investigation.create!(@valid_attributes)
    BASE_EMBEDDABLES.each do |e|
      @investigation.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize).should be(true)
    end
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

    it "should find all grade 8 phsysics investigations, including drafts" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        inv.domain.should == @physics
        inv.grade_span.should == @eight
      end
    end

  
    it "should find all grade phsysics investigations, including drafts" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        inv.domain.should == @physics
      end
    end

    it "should find all public and draft investigations" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.should include(*@drafts)
      found.should include(*@published)
    end

    it "should find all public and draft NON-GSE investigations too" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.should include(@public_non_gse)
      found.should include(@draft_non_gse)
    end
    
    it "should find only published, in grade 8 physics domain" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
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

    it "should find only published in physics domain" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :domain_id  => [@physics.id],
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
      pending "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      found.should include(*@published)
      found.should include(@public_non_gse)
      found.should_not include(*@drafts)
    end
    it "should search investigations that require probes" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false,
        :probe_type => [@probe_type.id]
      }
      found = Investigation.search_list(options)
      assert_equal found.length, 1
      found.should include(@investigation)
    end
    it "should search investigations that does require probes" do
      pending "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false,
        :probe_type => ['0']
      }
      found = Investigation.search_list(options)
      found.should_not include(@investigation)
    end
  end 

  describe "with activities" do
    let (:inv_attributes) { {
        :name => "test investigation",
        :description => "new decription"
      } }
    let (:investigation) { Factory.create(:investigation, inv_attributes) }
    let (:activity_one)  { Factory.create(:activity) }
    let (:activity_two)  { Factory.create(:activity) }

    # We might want to have one activity in the future. 
    it "should have no activities initially" do
      investigation.should have(0).activities
    end

    it "should have one activity after it is added" do
      investigation.activities << activity_one
      investigation.should have(1).activities
    end

    it "the position of the first activity should be 1" do
      investigation.activities << activity_one
      activity_one.insert_at(1)
      investigation.should have(1).activities
      activity_one.position.should_not be_nil
      activity_one.position.should eql 1
    end

    it "the position of the second activity should be 2" do
      investigation.activities << activity_one
      investigation.activities << activity_two
      investigation.should have(2).activities
      activity_one.insert_at(1)
      activity_two.insert_at(2)
      activity_one.position.should eql 1
      activity_two.position.should eql 2
    end

    it "the activities honor the acts_as_list methods" do
      investigation.activities << activity_one
      investigation.activities << activity_two
      activity_one.insert_at(1)
      activity_two.insert_at(2)
      
      investigation.reload
      investigation.activities.should eql([activity_one, activity_two])

      activity_one.move_to_bottom
      investigation.reload
      investigation.activities.should eql([activity_two, activity_one])
      
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
    before(:each) do
      @investigation = Factory(:investigation)
      @activity = Factory(:activity)
      @section = Factory(:section)
      @page = Factory(:page)
      @m_choice = Factory(:multiple_choice)
      @m_choice_b = Factory(:multiple_choice)
      @sub_page = Factory(:page)
      @sub_page.page_elements << Factory(:page_element, :embeddable => @m_choice)
      @page.page_elements << Factory(:page_element, :embeddable => @m_choice_b)
      @section.pages << @page
      @activity.sections << @section
      @investigation.activities << @activity
    end

    it "should have 1 multiple choices" do
      @investigation.should have(1).reportable_elements
      @investigation.reportable_elements.each do |elm|
        elm[:embeddable].should be_a(Embeddable::MultipleChoice)
      end
    end
  end

  describe "finding and cleaning broken investigations" do
    before :each do
      @bad  = Investigation.create!(@valid_attributes)
      @good = Investigation.create!(@valid_attributes)
      @bad_with_learners  = Investigation.create!(@valid_attributes)
      @offering = mock_model(Portal::Offering, :can_be_deleted? => false)
      @bad_page_element = mock_model(PageElement, :embeddable => nil)
      @good_page_element = mock_model(PageElement, :embeddable => mock_model(Embeddable::MultipleChoice))
      @good.stub(:page_elements => [@good_page_element,@good_page_element])
      @bad.stub(:page_elements => [@good_page_element, @bad_page_element, @good_page_element])
      @bad_with_learners.stub(:page_elements => [@good_page_element, @bad_page_element, @good_page_element])
      @bad_with_learners.stub(:offerings => [@offering])
      Investigation.stub!(:all => [@good,@bad,@bad_with_learners])     
    end

    describe "broken investigations" do
      describe "broken_parts" do
        it "should return a list of a broken page_elements" do
          @bad.broken_parts.should_not be_empty
          @bad_with_learners.broken_parts.should_not be_empty
        end
        it "should return an empty list if the investigation is fine" do
          @good.broken_parts.should be_empty
        end
      end
      
      describe "broken?" do
        it "investigation with broken parts should be marked as broken" do
          @good.should_not be_broken
          @bad.should be_broken
          @bad_with_learners.should be_broken
        end
      end

      describe "Investigation#broken" do
        it "should return a list of broken investigations" do
          Investigation.broken.should include @bad
          Investigation.broken.should_not include @good
        end
      end
    end #broken investigations

    describe "deleting broken investigations" do
      describe "can_be_modified?" do
        it "should return true for investigations without learners" do
          @good.should be_can_be_modified
          @bad.should be_can_be_modified
        end
        it "should return false for investigations with learners" do
          @bad_with_learners.should_not be_can_be_modified
        end
      end

      describe "can_be_deleted?" do
        it "should return true for investigations without learners" do
          @good.can_be_deleted?.should == true
          @bad.can_be_deleted?.should == true
        end
        it "should return false for investigations with learners" do
          @bad_with_learners.can_be_deleted?.should == false
        end
      end

      describe "delete_broken" do
        it "should send 'destroy' messages to broken investigations without learners" do
          @bad_with_learners.should_not_receive(:destroy)
          @good.should_not_receive(:destroy)
          @bad.should_receive(:destroy)
          Investigation.delete_broken
        end
      end
    end # deleting broken investigations
  end

  describe "#is_template method" do
    let(:investigation)        { nil }
    let(:external_activities)  { [] }
    let(:activity_externals)    { [] }
    let(:activity)             { mock(:external_activities => activity_externals) }
    let(:activities)           { [activity] }
    subject do
      s = Factory.create(:investigation)
      s.stub!(:external_activities => external_activities)
      s.stub!(:activities => activities)
      s.is_template
    end
    describe "when an investigation has an activity that is a template" do
      let(:activity_externals) { [1,2,3] }
      it { should be_true }
    end
    describe "when an investigation has an activity that is not a template" do
      describe "when an investigation has external_activities" do
        let(:external_activities) { [1,2,3]}
        it { should be_true}
      end
      describe "when an investigation has no external_activities" do
        let(:external_activities) {[]}
        it { should be_false}
      end
    end  
  end

  describe '#is_template scope' do
    before(:each) do
      e1 = Factory.create(:external_activity)
      e2 = Factory.create(:external_activity)
      a = Factory.create(:activity, external_activities: [e2])
      @i1 = Factory.create(:investigation)
      @i2 = Factory.create(:investigation, external_activities: [e1])
      @i3 = Factory.create(:investigation, activities: [a])
    end

    it 'should return investigations which are not templates if provided argument is false' do
      expect(Investigation.is_template(false).count).to eql(1)
      expect(Investigation.is_template(false).first).to eql(@i1)
    end

    it 'should return investigations which are templates if provided argument is true' do
      expect(Investigation.is_template(true).count).to eql(2)
      expect(Investigation.is_template(true).first).to eql(@i2)
      expect(Investigation.is_template(true).last).to eql(@i3)
    end
  end

  describe "project support" do
    let (:investigation) { Factory.create(:investigation) }
    let (:project) { FactoryGirl.create(:project) }

    it "can be assigned to a project" do
      investigation.projects << project
      expect(investigation.projects.count).to eql(1)
    end
  end
end


