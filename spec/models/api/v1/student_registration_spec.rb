# encoding: utf-8
require 'spec_helper'

describe API::V1::StudentRegistration do
  before(:each) do
    API::V1::StudentRegistration.any_instance.stub(:valid_class_word_checker).and_return(true)
    API::V1::StudentRegistration.any_instance.stub(:num_required_questions).and_return(3)
  end

  let(:questions) { ["a","b","c"] }
  let(:answers)   { ["d","e","f"] }
  let(:params) {
     { 
        first_name: "student",
        last_name: "doe",
        password: "testingxxy",
        class_word: "abc123",
        questions: questions,
        answers: answers
    }
  }
  
  it_behaves_like 'user registration' do
    let(:good_params) { params }
  end

  describe "Failing student validations" do
    subject { API::V1::StudentRegistration.new(params) }
    describe "missing questions" do
      let(:questions) { ["a","b"] }
      it { should have(1).error_on :"questions[2]" }
    end

    describe "duplicate questions" do
      let(:questions) { ["a","a","b"] }
      it { should have(1).error_on :"questions[1]" }
    end

    describe "missing answers" do
      let(:answers) { ["a","b"] }
      it { should have(1).error_on :"answers[2]" }
    end

    describe "blank answers" do
      let(:answers) { [nil,""," "] }
      it { should have(1).error_on :"answers[0]" }
      it { should have(1).error_on :"answers[1]" }
      it { should have(1).error_on :"answers[2]" }
    end
  end

  describe "#make_security_questions" do
    before(:each) do
      API::V1::StudentRegistration.any_instance.stub(:user).and_return(mock_model(User))
    end
    subject    { API::V1::StudentRegistration.new(params).make_security_questions }
    its(:size) { should be 3 }
    it "should contain valid questions" do
      subject.each do  |question|
        question.should be_valid
      end
    end
  end

  describe "#save" do
    subject       { 
      registration = API::V1::StudentRegistration.new(params) 
      registration.save
      registration
    }
    its(:user)    { should be_valid }
    its(:student) { should be_valid }
  end

end      