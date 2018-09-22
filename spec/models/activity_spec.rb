require File.expand_path('../../spec_helper', __FILE__)

describe Activity do
  let (:valid_attributes) { {
    :name => "test activity",
    :description => "new decription"
  } }
  let (:activity) { FactoryBot.create(:activity, valid_attributes) }

  it "should create a new instance given valid attributes" do
    activity.valid?
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
    let (:seven) { "7" }
    let (:eight) { "8" }

    let (:invs) do
      [
        {
          :name                   => "grade 7 physics"
        },
        {
          :name                   => "grade 8 physics"
        },
        {
          :name                   => "grade 7 bio"
        },
        {
          :name                   => "grade 8 bio"
        },
      ]
    end

    let (:published) do
      pub = []
      invs.each do |inv|
        investigation = FactoryBot.create(:investigation, inv)
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
        published_activity = FactoryBot.create(:activity, :name => "activity for #{inv.name}" ,:investigation_id => inv.id)
        draft = FactoryBot.create(:investigation, :name => inv.name, :grade_span_expectation => inv.grade_span_expectation)
        draft.name << " (draft) "
        draft.save
        dra << draft.reload
        drafts_activity = FactoryBot.create(:activity, :name => "activity for #{draft.name}" ,:investigation_id => draft.id)
      end
      dra
    end

    let (:public_non_gse)          { FactoryBot.create(:investigation, :name => "published non-gse investigation", :publication_status => 'Published') }
    let (:public_non_gse_activity) { FactoryBot.create(:activity, :name => "activity for #{public_non_gse.name}" ,:investigation_id => public_non_gse.id) }
    let (:draft_non_gse)           { FactoryBot.create(:investigation, :name => "draft non-gse investigation") }
    let (:draft_non_gse_activity)  { FactoryBot.create(:activity, :name => "activity for #{draft_non_gse.name}" ,:investigation_id => draft_non_gse.id) }
  end

  describe "#is_template method" do
    let(:investigation_with_template)    { mock_model(Investigation, :external_activities =>[1,2,3])}
    let(:investigation_without_template) { mock_model(Investigation, :external_activities =>[] )}
    let(:investigation)        { nil }
    let(:external_activities)  { [] }
    subject do
      s = FactoryBot.create(:activity)
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
      e1 = FactoryBot.create(:external_activity)
      e2 = FactoryBot.create(:external_activity)
      i = FactoryBot.create(:investigation, external_activities: [e2])
      @a1 = FactoryBot.create(:activity)
      @a2 = FactoryBot.create(:activity, external_activities: [e1])
      @a3 = FactoryBot.create(:activity, investigation: i)
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

  describe "question_number" do
    before(:each) do
      allow(activity_with_questions).to receive(:reportable_elements).and_return(elements)
    end
    let(:activity_with_questions) { activity }
    let(:mc_question)         {FactoryBot.create(:multiple_choice) }
    let(:or_question)         {FactoryBot.create(:open_response)   }
    let(:another_or_question) {FactoryBot.create(:open_response)   }
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
    let (:activity) { FactoryBot.create(:external_activity) }
    let (:project) { FactoryBot.create(:project) }

    it "can be assigned to a project" do
      activity.projects << project
      expect(activity.projects.count).to eql(1)
    end
  end

  # TODO: auto-generated
  describe '.without_teacher_only' do # scope test
    it 'supports named scope without_teacher_only' do
      expect(described_class.limit(3).without_teacher_only).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.activity_group' do # scope test
    it 'supports named scope activity_group' do
      expect(described_class.limit(3).activity_group).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.like' do # scope test
    it 'supports named scope like' do
      expect(described_class.limit(3).like('name')).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.investigation' do # scope test
    it 'supports named scope investigation' do
      expect(described_class.limit(3).investigation).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.published' do # scope test
    # not useable without merge
    xit 'supports named scope published' do
      expect(described_class.limit(3).published).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.directly_published' do # scope test
    it 'supports named scope directly_published' do
      expect(described_class.limit(3).directly_published).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.assigned' do # scope test
    it 'supports named scope assigned' do
      expect(described_class.limit(3).assigned).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.ordered_by' do # scope test
    it 'supports named scope ordered_by' do
      expect(described_class.limit(3).ordered_by(nil)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.is_template' do # scope test
    it 'supports named scope is_template' do
      expect(described_class.limit(3).is_template('n')).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#student_only' do
    xit 'student_only' do
      activity = described_class.new
      result = activity.student_only

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      activity = described_class.new
      result = activity.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      activity = described_class.new
      result = activity.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#left_nav_panel_width' do
    it 'left_nav_panel_width' do
      activity = described_class.new
      result = activity.left_nav_panel_width

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#deep_xml' do
    it 'deep_xml' do
      activity = described_class.new
      result = activity.deep_xml

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_elements' do
    it 'reportable_elements' do
      activity = described_class.new
      result = activity.reportable_elements

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#question_number' do
    it 'question_number' do
      activity = described_class.new
      embeddable = FactoryBot.create(:open_response)
      result = activity.question_number(embeddable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_listing' do
    it 'print_listing' do
      activity = described_class.new
      result = activity.print_listing

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#full_title' do
    it 'full_title' do
      activity = described_class.new
      result = activity.full_title

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_official' do
    it 'is_official' do
      activity = described_class.new
      result = activity.is_official

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_template' do
    it 'is_template' do
      activity = described_class.new
      result = activity.is_template

      expect(result).not_to be_nil
    end
  end


end
