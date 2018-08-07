# encoding: utf-8
require 'spec_helper'

describe API::V1::TeacherRegistration do
  let(:params) {
     {
        first_name: "teacher",
        last_name: "doe",
        login: "teacher_user",
        password: "testingxxy",
        email: "teacher@concord.org",
        school_id: 123
    }
  }

  it_behaves_like 'user registration' do
    let(:good_params) { params }
    before(:each) do
      allow(Portal::School).to receive(:find).and_return(mock_model(Portal::School))
      allow(Portal::School).to receive(:exists?).and_return(true)
    end
  end

  describe "school_id validations" do
    subject { API::V1::TeacherRegistration.new(params) }

    describe "no school found" do
      before(:each) do
        allow(Portal::School).to receive(:exists?).and_return(false)
      end
      it {
        is_expected.not_to be_valid
        is_expected.to have(1).error_on :"school_id"
      }
    end

    describe "school found" do
      before(:each) do
        allow(Portal::School).to receive(:exists?).and_return(true)
      end
      it { is_expected.to be_valid }
    end
  end

  describe "teacher instance" do
    let (:teacher) {
      registration = API::V1::TeacherRegistration.new(params)
      registration.save
      registration.teacher
    }

    describe "when school is found" do
      before(:each) do
        allow(Portal::School).to receive(:exists?).and_return(true)
        allow(Portal::School).to receive(:find).and_return(mock_model(Portal::School, id: 123))
      end

      it "should have exactly one school" do
        expect(teacher.schools.size).to eq(1)
        expect(teacher.school.id).to eql(123)
      end
    end
  end
end
