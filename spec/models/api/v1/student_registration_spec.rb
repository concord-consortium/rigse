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


end
