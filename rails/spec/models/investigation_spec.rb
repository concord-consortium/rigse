require File.expand_path('../../spec_helper', __FILE__)

# matchers for acts_as_list

RSpec::Matchers.define :be_before do |expected|
  match                          { |given| given.position < expected.position }
  failure_message     { |given| "expected #{given.inspect} to be before #{expected.inspect}" }
  failure_message_when_negated { |given| "expected #{given.inspect} not to be before #{expected.inspect}" }
  description                    { "be before #{expected.position}" }
end

RSpec::Matchers.define :be_after do |expected|
  match                          { |given| given.position > expected.position }
  failure_message     { |given| "expected #{given.inspect} to be after #{expected.inspect}" }
  failure_message_when_negated { |given| "expected #{given.inspect} not to be after #{expected.inspect}" }
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

  describe "with activities" do
    let (:inv_attributes) { {
        :name => "test investigation",
        :description => "new decription"
      } }
    let (:investigation) { FactoryBot.create(:investigation, inv_attributes) }
    let (:activity_one)  { FactoryBot.create(:activity) }
    let (:activity_two)  { FactoryBot.create(:activity) }

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
      expect(investigation.activities.to_a).to eql([activity_one, activity_two])

      activity_one.move_to_bottom
      investigation.reload
      expect(investigation.activities.to_a).to eql([activity_two, activity_one])

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
      @investigation = FactoryBot.create(:investigation)
      @activity = FactoryBot.create(:activity)
      @section = FactoryBot.create(:section)
      @page = FactoryBot.create(:page)
      @m_choice = FactoryBot.create(:multiple_choice)
      @m_choice_b = FactoryBot.create(:multiple_choice)
      @sub_page = FactoryBot.create(:page)
      @sub_page.page_elements << FactoryBot.create(:page_element, :embeddable => @m_choice)
      @page.page_elements << FactoryBot.create(:page_element, :embeddable => @m_choice_b)
      @section.pages << @page
      @activity.sections << @section
      @investigation.activities << @activity
    end

    it "should have 1 multiple choices" do
      expect(@investigation.reportable_elements.size).to eq(1)
      @investigation.reportable_elements.each do |elm|
        expect(elm[:embeddable]).to be_a(Embeddable::MultipleChoice)
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
      allow(@good).to receive_messages(:page_elements => [@good_page_element,@good_page_element])
      allow(@bad).to receive_messages(:page_elements => [@good_page_element, @bad_page_element, @good_page_element])
      allow(@bad_with_learners).to receive_messages(:page_elements => [@good_page_element, @bad_page_element, @good_page_element])
      allow(@bad_with_learners).to receive_messages(:offerings => [@offering])
      allow(Investigation).to receive_messages(:all => [@good,@bad,@bad_with_learners])
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
      s = FactoryBot.create(:investigation)
      allow(s).to receive_messages(:external_activities => external_activities)
      allow(s).to receive_messages(:activities => activities)
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
      e1 = FactoryBot.create(:external_activity)
      e2 = FactoryBot.create(:external_activity)
      a = FactoryBot.create(:activity, external_activities: [e2])
      @i1 = FactoryBot.create(:investigation)
      @i2 = FactoryBot.create(:investigation, external_activities: [e1])
      @i3 = FactoryBot.create(:investigation, activities: [a])
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
    let (:investigation) { FactoryBot.create(:investigation) }
    let (:project) { FactoryBot.create(:project) }

    it "can be assigned to a project" do
      investigation.projects << project
      expect(investigation.projects.count).to eql(1)
    end
  end

  # TODO: auto-generated
  describe '.assigned' do # scope test
    it 'supports named scope assigned' do
      expect(described_class.limit(3).assigned).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.like' do # scope test
    it 'supports named scope like' do
      expect(described_class.limit(3).like('x')).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.activity_group' do # scope test
    it 'supports named scope activity_group' do
      expect(described_class.limit(3).activity_group).to all(be_a(described_class))
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
      expect(described_class.limit(3).is_template(false)).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#student_only' do
    xit 'student_only' do
      investigation = described_class.new
      result = investigation.student_only

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigation' do
    it 'investigation' do
      investigation = described_class.new
      result = investigation.investigation

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_author_role_to_use' do
    it 'add_author_role_to_use' do
      investigation = described_class.new
      result = investigation.add_author_role_to_use

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#left_nav_panel_width' do
    it 'left_nav_panel_width' do
      investigation = described_class.new
      result = investigation.left_nav_panel_width

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      investigation = described_class.new
      result = investigation.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      investigation = described_class.new
      result = investigation.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#deep_xml' do
    it 'deep_xml' do
      investigation = described_class.new
      result = investigation.deep_xml

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_listing' do
    it 'print_listing' do
      investigation = described_class.new
      result = investigation.print_listing

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_elements' do
    it 'reportable_elements' do
      investigation = described_class.new
      result = investigation.reportable_elements

      expect(result).not_to be_nil
    end
  end


  # TODO: auto-generated
  describe '#broken?' do
    it 'broken?' do
      investigation = described_class.new
      result = investigation.broken?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#can_be_modified?' do
    it 'can_be_modified?' do
      investigation = described_class.new
      result = investigation.can_be_modified?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#can_be_deleted?' do
    it 'can_be_deleted?' do
      investigation = described_class.new
      result = investigation.can_be_deleted?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.broken' do
    it 'broken' do
      result = described_class.broken

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.broken_report' do
    it 'broken_report' do
      result = described_class.broken_report

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.delete_broken' do
    it 'delete_broken' do
      result = described_class.delete_broken

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#full_title' do
    it 'full_title' do
      investigation = described_class.new
      result = investigation.full_title

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_official' do
    it 'is_official' do
      investigation = described_class.new
      result = investigation.is_official

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#is_template' do
    it 'is_template' do
      investigation = described_class.new
      result = investigation.is_template

      expect(result).not_to be_nil
    end
  end


end
