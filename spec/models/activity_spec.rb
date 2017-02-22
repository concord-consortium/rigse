require File.expand_path('../../spec_helper', __FILE__)

describe Activity do
  let (:valid_attributes) { {
    :name => "test activity",
    :description => "new decription"
  } }
  let (:activity) { FactoryGirl.create(:activity, valid_attributes) }

  it "should create a new instance given valid attributes" do
    activity.valid?
  end

  it 'should respond to #material_type' do
    expect(activity.material_type).to eq('Activity')
  end

  it "should be destroy'able" do
    activity.destroy
  end

  it 'has_many for all BASE_EMBEDDABLES' do
    expect(BASE_EMBEDDABLES.length).to be > 0
    BASE_EMBEDDABLES.each do |e|
      expect(activity.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize)).to be(true)
    end
  end

  describe "should be publishable" do
    it "should not be public by default" do
      expect(activity.published?).to be(false)
    end
    it "should be public if published" do
      activity.publish!
      expect(activity.public?).to be(true)
    end
    
    it "should not be public if unpublished " do
      activity.publish!
      expect(activity.public?).to be(true)
      activity.un_publish!
      expect(activity.public?).not_to be(true)
    end
  end

  describe "search_list (searching for activity)" do
    # Preserving these "let" blocks temporarily in case we need them to set up a structure to test elsewhere - pjm 2013/10/08
    let (:bio) { Factory.create( :rigse_domain, { :name => "biology" } ) }
    let (:seven) { "7" }
    let (:eight) { "8" }

    let (:bio_ks) { Factory.create( :rigse_knowledge_statement, { :domain => bio } ) }
    let (:bio_at) { Factory.create( :rigse_assessment_target, { :knowledge_statement => bio_ks } ) }

    let (:physics) { Factory.create( :rigse_domain, { :name => "physics" } ) }
    let (:physics_ks) { Factory.create( :rigse_knowledge_statement, { :domain => physics } ) }
    let (:physics_at) { Factory.create( :rigse_assessment_target, { :knowledge_statement => physics_ks }) }

    let (:physics_gse_grade7) { Factory.create( :rigse_grade_span_expectation, { :assessment_target => physics_at, :grade_span => seven } ) }
    let (:physics_gse_grade8) { Factory.create( :rigse_grade_span_expectation, { :assessment_target => physics_at, :grade_span => eight } ) }

    let (:bio_gse_grade7)     { Factory.create( :rigse_grade_span_expectation, { :assessment_target => bio_at, :grade_span => seven } ) }
    let (:bio_gse_grade8)     { Factory.create( :rigse_grade_span_expectation, { :assessment_target => bio_at, :grade_span => eight } ) }

    let (:invs) do
      [
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
    end

    let (:published) do
      pub = []
      invs.each do |inv|
        investigation = Factory.create(:investigation, inv)
        investigation.name << " (published) "
        investigation.publish!
        investigation.save
        pub << investigation.reload
      end
      pub
    end

    let (:drafts) do
      dra = []
      published.each do |inv|
        published_activity = Factory.create(:activity, :name => "activity for #{inv.name}" ,:investigation_id => inv.id)
        draft = Factory.create(:investigation, :name => inv.name, :grade_span_expectation => inv.grade_span_expectation)
        draft.name << " (draft) "
        draft.save
        dra << draft.reload
        drafts_activity = Factory.create(:activity, :name => "activity for #{draft.name}" ,:investigation_id => draft.id)
      end
      dra
    end

    let (:public_non_gse)          { Factory.create(:investigation, :name => "published non-gse investigation", :publication_status => 'Published') }
    let (:public_non_gse_activity) { Factory.create(:activity, :name => "activity for #{public_non_gse.name}" ,:investigation_id => public_non_gse.id) }
    let (:draft_non_gse)           { Factory.create(:investigation, :name => "draft non-gse investigation") } 
    let (:draft_non_gse_activity)  { Factory.create(:activity, :name => "activity for #{draft_non_gse.name}" ,:investigation_id => draft_non_gse.id) }

    #creating probe activities
    let (:investigation)            { Investigation.find_by_name_and_publication_status('grade 7 physics', 'published') }
    let (:probe_activity_published) { Factory.create(:activity, :name => 'probe_activity(published)', :publication_status => 'Published') }

    let (:section)      { Factory.create(:section, :activity_id => probe_activity_published.id) }
    let (:page)         { Factory.create(:page, :section_id => section.id) }
    let (:probe_type)   { Factory.create(:probe_type) }
    let (:embeddable_data_collectors) { Factory.create(:data_collector, :probe_type => probe_type) }
    let (:page_element) { Factory.create(:page_element, :page => page, :embeddable => embeddable_data_collectors) }
  end

  describe "#is_template method" do
    let(:investigation_with_template)    { mock_model(Investigation, :external_activities =>[1,2,3])}
    let(:investigation_without_template) { mock_model(Investigation, :external_activities =>[] )}
    let(:investigation)        { nil }
    let(:external_activities)  { [] }
    subject do
      s = Factory.create(:activity)
      allow(s).to receive_messages(:investigation => investigation)
      allow(s).to receive_messages(:external_activities => external_activities)
      s.is_template
    end

    describe "when an activity has external_activities" do
      let(:external_activities) { [1,2,3]}
      it { is_expected.to be_truthy}
    end
    describe "when an activity has no external_activities" do
      let(:external_activities) {[]}
      it { is_expected.to be_falsey}

      describe "when the activity has an investigation" do
        describe "that is a template" do
          let(:investigation) { investigation_with_template }
          it { is_expected.to be_truthy }
        end
        describe "that is not a template" do
          let(:investigation) { investigation_without_template }
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#is_template scope' do
    before(:each) do
      e1 = Factory.create(:external_activity)
      e2 = Factory.create(:external_activity)
      i = Factory.create(:investigation, external_activities: [e2])
      @a1 = Factory.create(:activity)
      @a2 = Factory.create(:activity, external_activities: [e1])
      @a3 = Factory.create(:activity, investigation: i)
    end

    it 'should return activities which are not templates if provided argument is false' do
      expect(Activity.is_template(false).count).to eql(1)
      expect(Activity.is_template(false).first).to eql(@a1)
    end

    it 'should return activities which are templates if provided argument is true' do
      expect(Activity.is_template(true).count).to eql(2)
      expect(Activity.is_template(true).first).to eql(@a2)
      expect(Activity.is_template(true).last).to eql(@a3)
    end
  end

  describe "abstract_text" do
    let(:big_text) { "-xyzzy" * 255 }
    let(:description) do 
      "This is the description. Its text is too long to be an abstract really: #{big_text}"
    end

    subject { Factory.create(:activity, :description => description).abstract_text }

    it { is_expected.to match /This is the description./ }

    it 'has at most 255 letters' do
      expect(subject.size).to be <= 255
    end
  end

  describe "question_number" do
    before(:each) do
      allow(activity_with_questions).to receive(:reportable_elements).and_return(elements)
    end
    let(:activity_with_questions) { activity }
    let(:mc_question)         {Factory.create(:multiple_choice) }
    let(:or_question)         {Factory.create(:open_response)   }
    let(:another_or_question) {Factory.create(:open_response)   }
    let(:elements) {[
      {:activity => activity_with_questions, :embeddable => mc_question},
      {:activity => activity_with_questions, :embeddable => or_question}
    ]}
    subject() { activity_with_questions }

    it "should find the multiple choice question in the first position" do
      expect(subject.question_number(mc_question)).to eq 1
    end

    it "should find the open response question at the second position" do
      expect(subject.question_number(or_question)).to eq 2
    end

    it "should return -1 for questions that aren't supposed to be there... " do
      expect(subject.question_number(another_or_question)).to eq -1
    end

    it "should return -1 when nonesense is passed in " do
      expect(subject.question_number("xxx")).to eq -1
    end
  end

  describe "project support" do
    let (:activity) { Factory.create(:external_activity) }
    let (:project) { FactoryGirl.create(:project) }

    it "can be assigned to a project" do
      activity.projects << project
      expect(activity.projects.count).to eql(1)
    end
  end
end
