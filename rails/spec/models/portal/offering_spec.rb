require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Offering do

  describe "after being created" do
    let(:runnable) { FactoryBot.create(:external_activity) }
    let(:args)     { {runnable: runnable} }
    let(:offering) { FactoryBot.create(:portal_offering, args) }
    let(:student)  { FactoryBot.create(:full_portal_student) }
    let(:user_offering_active) { true }
    let(:user_offering_metadata) {
      FactoryBot.create(:user_offering_metadata, user: student.user, offering: offering, active: user_offering_active)
    }

    it "should be active by default" do
     expect(offering.active).to be_truthy
     expect(offering.active?).to be_truthy
     expect(offering.active?(nil)).to be_truthy
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

    describe "can be overridden by user metadata" do
      before(:each) do
        user_offering_metadata # ensure metadata is created
      end

      describe "when offering is active and user metadata is active" do
        it "should be active? and should_show? when not archived" do
          expect(offering.active?).to be_truthy
          expect(offering.should_show?).to be_truthy
          expect(offering.active?(student.user)).to be_truthy
          expect(offering.should_show?(student.user)).to be_truthy
        end

        it "should not should_show? when archived" do
          offering.runnable.archive!
          expect(offering.should_show?).to be_falsey
          expect(offering.should_show?(student.user)).to be_falsey
        end
      end

      describe "when offering is active and user metadata is not active" do
        let(:user_offering_active) { false }

        it "should be active? and should_show? when user is not passed" do
          expect(offering.active?).to be_truthy
          expect(offering.should_show?).to be_truthy
        end

        it "should not be active? and not should_show? when user is passed" do
          expect(offering.active?(student.user)).to be_falsey
          expect(offering.should_show?(student.user)).to be_falsey
        end
      end

      describe "when offering is not active and user metadata is active" do
        it "should not be active? and not should_show? when user is not passed" do
          offering.deactivate!
          expect(offering.active?).to be_falsey
          expect(offering.should_show?).to be_falsey
        end

        it "should be active? and should_show? when not archived and user is passed" do
          offering.deactivate!
          expect(offering.active?(student.user)).to be_truthy
          expect(offering.should_show?(student.user)).to be_truthy
        end

        it "should not should_show? when archived" do
          offering.runnable.archive!
          expect(offering.should_show?).to be_falsey
          expect(offering.should_show?(student.user)).to be_falsey
        end
      end

      describe "when offering is not active and user metadata is not active" do
        let(:user_offering_active) { false }

        it "should not be active? and not should_show?" do
          offering.deactivate!
          expect(offering.active?).to be_falsey
          expect(offering.should_show?).to be_falsey
          expect(offering.active?(student.user)).to be_falsey
          expect(offering.should_show?(student.user)).to be_falsey
        end
      end
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
        expect {offering.destroy!}.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
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
