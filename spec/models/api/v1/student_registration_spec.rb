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

end      