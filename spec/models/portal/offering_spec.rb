require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Offering do
  
  describe "after being created" do
    let(:runnable) { FactoryBot.create(:external_activity) }
    let(:args)     { {runnable: runnable} }
    let(:offering) { FactoryBot.create(:portal_offering, args) }

    it "should be active by default" do
     expect(offering.active).to be_truthy
     expect(offering.active?).to be_truthy
    end
    
    it "can be deactivated" do
     expect(offering.active?).to be_truthy
     offering.deactivate!
      
     expect(offering.active).to be_falsey
     expect(offering.active?).to be_falsey
    end
    
    it "can be activated" do
     offering.deactivate!
     expect(offering.active?).to be_falsey
      
     offering.activate!
     expect(offering.active?).to be_truthy
    end

    describe "should_be_shown" do
      describe "when the runable is archived" do
        before(:each) { allow(runnable).to receive(:archived?).and_return(true) }
        it "should always be deactivated" do
          expect(offering.should_show?).to be_falsey
        end
        it "should still be deactivated after activating" do
          offering.activate!
          expect(offering.should_show?).to be_falsey
        end
      end
    end

    describe "delegates whether the student report" do
      it "is enabled" do
        runnable.student_report_enabled = true
        expect(offering.student_report_enabled?).to be_truthy
      end

      it "is disabled" do
        runnable.student_report_enabled = false
        expect(offering.student_report_enabled?).to be_falsey
      end
    end

    describe "an offering with learners" do
      let(:learner) { FactoryBot.build(:portal_learner) }
      let(:args)    { {runnable: runnable, learners: [learner]} }
      before(:each) { allow(learner).to receive(:valid?).and_return(true) }

      # this is probably not a good approach, it makes it heard for cleaning up learner data
      # and assignments when we really want to. It blocks all of the dependent destroy definitions
      # from being used
      it "can not be destroyed" do
        expect(offering.destroy).to be false
        expect {offering.destroy!}.to raise_error(NoMethodError)
      end
    end
  end

  describe '#answered' do
    it 'answered for open responses' do
      offering = described_class.new
      result = offering.open_responses.answered

      expect(result).to be_empty
    end
  end

  describe '#answered' do
    it 'answered for multiple_choices' do
      offering = described_class.new
      result = offering.multiple_choices.answered

      expect(result).to be_empty
    end
  end

  describe '#answered_correctly' do
    it 'answered for multiple_choices' do
      offering = described_class.new
      result = offering.multiple_choices.answered_correctly

      expect(result).to be_empty
    end
  end

  describe '#for_embeddable' do
    it 'answered for metadata' do
      offering = described_class.new
      dummy = offering
      result = offering.metadata.for_embeddable(dummy)

      expect(result).to be_nil
    end
  end

  describe '#sessions' do
    it 'sessions' do
      offering = described_class.new
      result = offering.sessions

      expect(result).not_to be_nil
    end
  end

  describe '#saveables' do
    it 'saveables' do
      offering = described_class.new
      result = offering.saveables

      expect(result).to be_empty
    end
  end

  describe '#printable_report?' do
    it 'printable_report?' do
      offering = described_class.new
      result = offering.printable_report?

      expect(result).not_to be_nil
    end
  end

  describe '#completed_students_count' do
    it 'completed_students_count' do
      offering = described_class.new
      offering.clazz = Portal::Clazz.new
      result = offering.completed_students_count

      expect(result).not_to be_nil
    end
  end

  describe '#inprogress_students_count' do
    it 'inprogress_students_count' do
      offering = described_class.new
      offering.clazz = Portal::Clazz.new
      result = offering.inprogress_students_count

      expect(result).not_to be_nil
    end
  end

  describe '#notstarted_students_count' do
    it 'notstarted_students_count' do
      offering = described_class.new
      offering.clazz = Portal::Clazz.new
      result = offering.notstarted_students_count

      expect(result).not_to be_nil
    end
  end

  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      offering = described_class
      result = offering.searchable_attributes

      expect(result).not_to be_nil
    end
  end
end
