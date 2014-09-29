# encoding: utf-8
require 'spec_helper'

describe API::V1::CollaborationBuilder do
  let(:student1) { Factory(:full_portal_student) }
  let(:student2) { Factory(:full_portal_student) }
  let(:students) { [student1, student2] }
  let(:offering) { Factory(:portal_offering) }
  let(:clazz) do
    clazz = offering.clazz
    clazz.students = [student1, student2]
    clazz.save!
    clazz
  end
  let(:params) do
    {
      offering_id: offering.id,
      owner_id: student1.id,
      students: [
        {
          id: student1.id,
          password: 'password' # this is valid password, see users factory.
        },
        {
          id: student2.id,
          password: 'password'
        }
      ]
    }
  end

  describe "Failing collaboration validations" do
    subject { API::V1::CollaborationBuilder.new(params) }

    describe "missing owner" do
      before { params.delete(:owner_id) }
      it { should have(1).error_on :owner_id }
    end

    describe "missing offering" do
      before { params.delete(:offering_id) }
      it { should have(1).error_on :offering_id }
    end

    describe "incorrect student password" do
      before { params[:students][0][:password] = "wrong_password" }
      it { should have(1).error_on :"students[0]" }
    end

    describe "incorrect student ID" do
      before { params[:students][1][:id] = 99999999 }
      it { should have(1).error_on :"students[1]" }
    end
  end

  describe "#save" do
    it "should return true when successful" do
      expect(API::V1::CollaborationBuilder.new(params).save).to be true
    end

    it "should return false when params are incorrect" do
      expect(API::V1::CollaborationBuilder.new({}).save).to be false
    end

    describe "collaboration object (Portal::Collaboration instance)" do
      let (:collaboration) do
        cbuilder = API::V1::CollaborationBuilder.new(params)
        cbuilder.save
        cbuilder.collaboration
      end

      it "should have the correct owner" do
        expect(collaboration.owner.id).to eql(params[:owner_id])
      end

      it "should have the correct students (collaborators)" do
        expect(collaboration.students).to match_array(students)
      end

      describe "when owner isn't provided in students list" do
        before { params[:students].delete_at(0) }
        it "it should be added to collaborators anyway" do
          expect(collaboration.students).to match_array(students)
        end
      end

      describe "when offering is a JNLP activity or sequence" do
        it "should have #bundle_content set to owner's bundle" do
          learner = offering.find_or_create_learner(collaboration.owner)
          expected_bundle = learner.bundle_logger.in_progress_bundle
          expect(collaboration.bundle_content).to eql(expected_bundle)
        end
      end

      describe "when offering is an external activity" do
        before { params[:external_activity] = true }
        it "should have #bundle_content equal to nil" do
          expect(collaboration.bundle_content).to eql(nil)
        end
      end
    end

    describe "side effects of collaboration generation" do
      let (:cbuilder) { API::V1::CollaborationBuilder.new(params) }

      it "should generate learner objects for every student" do
        expect(offering.learners.length).to eql(0)
        cbuilder.save
        offering.reload
        expect(offering.learners.map { |l| l.student }).to match_array(students)
      end

      describe "when offering is a JNLP activity or sequence" do
        it "should start Dataservice event" do
          expect(Dataservice::LaunchProcessEvent.count).to eql(0)
          cbuilder.save
          expect(Dataservice::LaunchProcessEvent.count).to eql(1)
        end
      end
    end
  end

end
