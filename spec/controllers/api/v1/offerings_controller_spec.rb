require 'spec_helper'

describe API::V1::OfferingsController do

  let(:admin_user)        { Factory.next(:admin_user)     }
  let(:simple_user)       { Factory.next(:confirmed_user) }
  let(:manager_user)      { Factory.next(:manager_user)   }
  let(:teacher)           { Factory.create(:portal_teacher)}

  let(:fake_json)         { {fake:true}.to_json  }
  let(:mock_offering)     { mock_model Portal::Offering }
  let(:mock_api_offering) { mock(to_json: fake_json) }
  let(:mock_offering_id)  { 32 }
  let(:offering_teachers) { [] }

  before(:each) do
    Portal::Offering.stub!(:find).and_return(mock_offering)
    mock_offering.stub_chain(:clazz, :is_teacher?).and_return { |t| offering_teachers.include?(t) }
  end

  describe "anonymous' access" do
    before (:each) do
      logout_user
    end

    describe "GET show" do
      it "wont allow show, returns error 403" do
        get :show, :id => mock_offering_id
        response.status.should eql(403)
      end
    end
  end

  describe "manager access" do
    before (:each) do
      sign_in manager_user
    end
    describe "GET show" do
      it "wont allow show, returns error 403" do
        get :show, :id => mock_offering_id
        response.status.should eql(403)
      end
    end
  end

  describe "admin access" do
    before (:each) do
      sign_in admin_user
      API::V1::Offering.should_receive(:new).and_return(mock_api_offering)
    end
    describe "GET show" do
      it "renders the show template" do
        get :show, :id => mock_offering_id
        assigns[:offering_api].should eq mock_api_offering
        response.status.should eq 200
        response.body.should eq fake_json
      end
    end
  end

  describe "teacher access" do
    let(:offering_teachers) { [] }
    before(:each) do
      sign_in teacher.user
    end
    describe "when the offering doesn't belong to the teachers class" do
      let(:offering_teachers) { [] }
      it "wont allow show, returns error 403" do
        get :show, :id => mock_offering_id
        response.status.should eql(403)
      end
    end

    describe "when the offering belongs to the teachers class" do
      let(:offering_teachers) { [teacher.user] }
      describe "GET show" do
        it "renders the show template" do
          API::V1::Offering.should_receive(:new).and_return(mock_api_offering)
          get :show, :id => mock_offering_id
          assigns[:offering_api].should eq mock_api_offering
          response.status.should eq 200
          response.body.should eq fake_json
        end
      end
    end

  end

end
