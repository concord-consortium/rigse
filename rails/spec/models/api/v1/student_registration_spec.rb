# encoding: utf-8
require 'spec_helper'

describe API::V1::StudentRegistration do
  before(:each) do
    allow_any_instance_of(API::V1::StudentRegistration).to receive(:valid_class_word_checker).and_return(true)
  end

  let(:params) {
     { 
        first_name: "student",
        last_name: "doe",
        password: "testingxxy",
        class_word: "abc123"
    }
  }
  
  it_behaves_like 'user registration' do
    let(:good_params) { params }
  end

  describe "#save" do
    subject       { 
      registration = API::V1::StudentRegistration.new(params) 
      registration.save
      registration
    }

    describe '#user' do
      subject { super().user }
      it { is_expected.to be_valid }
    end

    describe '#student' do
      subject { super().student }
      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    context "given duplicate user names" do
      it "creates unique logins" do

        @count = User.count

        reg1 = API::V1::StudentRegistration.new(params)
        reg1.save

        #
        # Set the login attribute to be the login we know was created
        # by the previous save. Note this requires the test to have
        # some knowledge of the implementation. Should the implementation
        # change (or even the interface e.g. attribute access) then this
        # test might no longer be valid.
        #
        # See bug PT #109387108
        #
        reg2 = API::V1::StudentRegistration.new(params)
        reg2.login = 'sdoe'
        reg2.save

        expect(User.count).to eql(@count + 2)

      end
    end
  end




  # TODO: auto-generated
  describe '#make_login' do
    it 'make_login' do
      student_registration = described_class.new
      result = student_registration.make_login

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#make_email' do
    it 'make_email' do
      student_registration = described_class.new
      result = student_registration.make_email

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_defaults' do
    it 'set_defaults' do
      student_registration = described_class.new
      result = student_registration.set_defaults

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#valid_class_word_checker' do
    it 'valid_class_word_checker' do
      student_registration = described_class.new
      result = student_registration.valid_class_word_checker

      expect(result).not_to be_nil
    end
  end


end
