# encoding: utf-8
require 'spec_helper'

describe API::V1::StudentRegistration do
  before(:each) do
    API::V1::StudentRegistration.any_instance.stub(:valid_class_word_checker).and_return(true)
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
    its(:user)    { should be_valid }
    its(:student) { should be_valid }
  end

end      