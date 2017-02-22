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
    expect(BASE_EMBEDDABLES.length).to be > 0
    @investigation = Investigation.create!(@valid_attributes)
    BASE_EMBEDDABLES.each do |e|
      expect(@investigation.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize)).to be(true)
    end
  end

  describe "should be publishable" do
    before(:each) do
      @investigation = Investigation.create!(@valid_attributes)
    end
    
    it "should not be public by default" do
      expect(@investigation.published?).to be(false)
    end
    it "should be public if published" do
      @investigation.publish!
      expect(@investigation.public?).to be(true)
    end
    
    it "should not be public if unpublished " do
      @investigation.publish!
      expect(@investigation.public?).to be(true)
      @investigation.un_publish!
      expect(@investigation.public?).not_to be(true)
    end
    
    it "should define a method for available_states" do
      expect(@investigation).to respond_to(:available_states)
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
        
        expect(@investigation.duplicateable?(@user)).to be_falsey
      end
    end
    
    it "should allow admins, managers, etc. to duplicate" do
      [:admin, :manager, :researcher, :author].each do |role|
        @user.roles.destroy_all
        @user.add_role(role.to_s)
        
        expect(@investigation.duplicateable?(@user)).to be_truthy
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

    # before(:each) do
    #   @bio = Factory.create( :rigse_domain,            { :name => "biology" } )
    #   bio_ks = Factory.create( :rigse_knowledge_statement, { :domain => @bio     } )
    #   bio_at = Factory.create( :rigse_assessment_target,       { :knowledge_statement => bio_ks })
    #   
    #   @physics = Factory.create( :rigse_domain,            { :name => "physics"  } )
    #   physics_ks = Factory.create( :rigse_knowledge_statement, { :domain => @physics  } )
    #   physics_at = Factory.create( :rigse_assessment_target,       { :knowledge_statement => physics_ks })
    #   
    #   @seven = "7"
    #   @eight = "8"
    # 
    #   physics7  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @seven} )
    #   physics8  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => physics_at, :grade_span => @eight} )
    # 
    #   bio7      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @seven} )
    #   bio8      = Factory.create( :rigse_grade_span_expectation, {:assessment_target => bio_at, :grade_span => @eight} )
    # 
    #   invs = [
    #     {
    #       :name                   => "grade 7 physics",
    #       :grade_span_expectation => physics7
    #     },
    #     {
    #       :name                   => "grade 8 physics",
    #       :grade_span_expectation => physics8
    #     },
    #     {
    #       :name                   => "grade 7 bio",
    #       :grade_span_expectation => bio7
    #     },
    #     {
    #       :name                   => "grade 8 bio",
    #       :grade_span_expectation => bio8
    #     },
    #   ]
    #   @published = []
    #   @drafts = []
    #   invs.each do |inv|
    #     published = Factory.create(:investigation, inv)
    #     published.name << " (published) "
    #     published.publish!
    #     published.save
    #     @published << published.reload
    #     draft = Factory.create(:investigation, inv)
    #     draft.name << " (draft) "
    #     draft.save
    #     @drafts << draft.reload
    #   end
    #   @public_non_gse = Factory.create(:investigation, :name => "published non-gse investigation");
    #   @public_non_gse.publish!
    #   @public_non_gse.save
    #   @public_non_gse.reload
    #   @draft_non_gse  = Factory.create(:investigation, :name => "draft non-gse investigation"); 
    # 
    #   @investigation = Investigation.find_by_name_and_publication_status('grade 7 physics', 'published')
    #   
    #   @probe_activity_published = Factory.create(:activity, :name => 'probe_activity(published)')
    #   @probe_activity_published.investigation = @investigation
    #   @probe_activity_published.save!
    #   
    #   section = Factory.create(:section)
    #   section.activity = @probe_activity_published
    #   section.save!
    #   
    #   page = Factory.create(:page)
    #   page.section = section
    #   page.save!
    #   
    #   page_element = PageElement.new
    #   page_element.id = 1
    #   page_element.page = page
    #   page_element.embeddable_type = 'Embeddable::DataCollector'
    #   page_element.save!
    #   
    #   embeddable_data_collectors = Factory.create(:data_collector)
    #   
    #   page_element.embeddable = embeddable_data_collectors
    #   page_element.save!
    #   
    #   @probe_type = Factory.create(:probe_type)
    #   embeddable_data_collectors.probe_type = @probe_type
    #   embeddable_data_collectors.save!
    # end
    # search (including drafts):
    # search for drafts in grade 8                # two entries
    
    it "should find all grade 8 phsysics investigations, including drafts" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        expect(inv.domain).to eq(@physics)
        expect(inv.grade_span).to eq(@eight)
      end
    end

  
    it "should find all grade phsysics investigations, including drafts" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :domain_id  => [@physics.id],
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      found.each do |inv|
        expect(inv.domain).to eq(@physics)
      end
    end

    it "should find all public and draft investigations" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      expect(found).to include(*@drafts)
      expect(found).to include(*@published)
    end

    it "should find all public and draft NON-GSE investigations too" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => true
      }
      found = Investigation.search_list(options)
      expect(found).to include(@public_non_gse)
      expect(found).to include(@draft_non_gse)
    end
    
    it "should find only published, in grade 8 physics domain" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :grade_span => [@eight],
        :domain_id  => [@physics.id],
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      expect(found.size).to eq(1)
      found.each do |inv|
        expect(inv).to be_public
        expect(inv.domain).to eq(@physics)
        expect(inv.grade_span).to eq(@eight)
      end
    end

    it "should find only published in physics domain" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :domain_id  => [@physics.id],
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      expect(found).not_to include(*@drafts)
      found.each do |inv|
        expect(inv).to be_public
        expect(inv.domain).to eq(@physics)
      end
    end
    
    it "should find all published investigations" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false
      }
      found = Investigation.search_list(options)
      expect(found).to include(*@published)
      expect(found).to include(@public_non_gse)
      expect(found).not_to include(*@drafts)
    end
    it "should search investigations that require probes" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false,
        :probe_type => [@probe_type.id]
      }
      found = Investigation.search_list(options)
      assert_equal found.length, 1
      expect(found).to include(@investigation)
    end
    it "should search investigations that does require probes" do
      skip "Equivalent spec suite elsewhere"
      options = {
        :include_drafts => false,
        :probe_type => ['0']
      }
      found = Investigation.search_list(options)
      expect(found).not_to include(@investigation)
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
      expect(investigation.activities.size).to eq(0)
    end

    it "should have one activity after it is added" do
      investigation.activities << activity_one
      expect(investigation.activities.size).to eq(1)
    end

    it "the position of the first activity should be 1" do
      investigation.activities << activity_one
      activity_one.insert_at(1)
      expect(investigation.activities.size).to eq(1)
      expect(activity_one.position).not_to be_nil
      expect(activity_one.position).to eql 1
    end

    it "the position of the second activity should be 2" do
      investigation.activities << activity_one
      investigation.activities << activity_two
      expect(investigation.activities.size).to eq(2)
      activity_one.insert_at(1)
      activity_two.insert_at(2)
      expect(activity_one.position).to eql 1
      expect(activity_two.position).to eql 2
    end

    it "the activities honor the acts_as_list methods" do
      investigation.activities << activity_one
      investigation.activities << activity_two
      activity_one.insert_at(1)
      activity_two.insert_at(2)
      
      investigation.reload
      expect(investigation.activities).to eql([activity_one, activity_two])

      activity_one.move_to_bottom
      investigation.reload
      expect(investigation.activities).to eql([activity_two, activity_one])
      
      # must reload the other activity for updated position.
      activity_two.reload
      expect(activity_two).to be_before(activity_one)
      expect(activity_one).to be_after(activity_two)
      
      # more fragile, but worth checking:
      expect(activity_one.position).to eql 2
      expect(activity_two.position).to eql 1
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
      expect(@investigation.reportable_elements.size).to eq(2)
      @investigation.reportable_elements.each do |elm|
        expect(elm[:embeddable]).to be_a(Embeddable::MultipleChoice)
      end
    end

    it "should not have any xhtmls" do
      @investigation.reportable_elements.each do |elm|
      expect(elm[:embeddable]).not_to be_a(Embeddable::Xhtml)
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
      Investigation.stub(:all => [@good,@bad,@bad_with_learners])
    end

    describe "broken investigations" do
      describe "broken_parts" do
        it "should return a list of a broken page_elements" do
          expect(@bad.broken_parts).not_to be_empty
          expect(@bad_with_learners.broken_parts).not_to be_empty
        end
        it "should return an empty list if the investigation is fine" do
          expect(@good.broken_parts).to be_empty
        end
      end
      
      describe "broken?" do
        it "investigation with broken parts should be marked as broken" do
          expect(@good).not_to be_broken
          expect(@bad).to be_broken
          expect(@bad_with_learners).to be_broken
        end
      end

      describe "Investigation#broken" do
        it "should return a list of broken investigations" do
          expect(Investigation.broken).to include @bad
          expect(Investigation.broken).not_to include @good
        end
      end
    end #broken investigations

    describe "deleting broken investigations" do
      describe "can_be_modified?" do
        it "should return true for investigations without learners" do
          expect(@good).to be_can_be_modified
          expect(@bad).to be_can_be_modified
        end
        it "should return false for investigations with learners" do
          expect(@bad_with_learners).not_to be_can_be_modified
        end
      end

      describe "can_be_deleted?" do
        it "should return true for investigations without learners" do
          expect(@good.can_be_deleted?).to eq(true)
          expect(@bad.can_be_deleted?).to eq(true)
        end
        it "should return false for investigations with learners" do
          expect(@bad_with_learners.can_be_deleted?).to eq(false)
        end
      end

      describe "delete_broken" do
        it "should send 'destroy' messages to broken investigations without learners" do
          expect(@bad_with_learners).not_to receive(:destroy)
          expect(@good).not_to receive(:destroy)
          expect(@bad).to receive(:destroy)
          Investigation.delete_broken
        end
      end
    end # deleting broken investigations
  end

  describe "#is_template method" do
    let(:investigation)        { nil }
    let(:external_activities)  { [] }
    let(:activity_externals)    { [] }
    let(:activity)             { double(:external_activities => activity_externals) }
    let(:activities)           { [activity] }
    subject do
      s = Factory.create(:investigation)
      s.stub(:external_activities => external_activities)
      s.stub(:activities => activities)
      s.is_template
    end
    describe "when an investigation has an activity that is a template" do
      let(:activity_externals) { [1,2,3] }
      it { is_expected.to be_truthy }
    end
    describe "when an investigation has an activity that is not a template" do
      describe "when an investigation has external_activities" do
        let(:external_activities) { [1,2,3]}
        it { is_expected.to be_truthy}
      end
      describe "when an investigation has no external_activities" do
        let(:external_activities) {[]}
        it { is_expected.to be_falsey}
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


  describe "abstract_text" do
    let(:abstract)    { nil }
    let(:big_text) { "-xyzzy" * 255 }
    let(:description) do 
      "This is the description. Its text is too long to be an abstract really: #{big_text}"
    end

    subject { Factory.create(:investigation, :abstract => abstract, :description => description).abstract_text }
    describe "without an abstract" do
      let(:abstract)         { nil }
      it { is_expected.to match /This is the description./ }
      it 'has at most 255 letters' do
        expect(subject.size).to be <= 255
      end
    end
    describe "without an empty abstract" do
      let(:abstract)         { " " }
      it { is_expected.to match /This is the description./ }
      it 'has at most 255 letters' do
        expect(subject.size).to be <= 255
      end
    end
    describe "without a good abstract" do
      let(:abstract)         { "This is the abstract." }
      it { is_expected.to match /This is the abstract./ }
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


