require 'spec_helper'

describe API::V1::OfferingsController do

  let(:admin_user)        { Factory.next(:admin_user)     }
  let(:simple_user)       { Factory.next(:confirmed_user) }
  let(:manager_user)      { Factory.next(:manager_user)   }
  let(:teacher)           { Factory.create(:portal_teacher)}

  let(:fake_json)         { {fake:true}.to_json  }
  let(:mock_offering)     { mock }
  let(:mock_api_offering) { mock(to_json: fake_json) }
  let(:mock_offering_id)  { 32 }


  describe "anonymous' access" do
    before (:each) do
      logout_user
    end
    describe "GET show" do
      it "wont allow show, redirects home" do
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
      it "wont allow show, redirects home" do
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
        assigns[:offering].should eq mock_api_offering
        response.status.should eq 200
        response.body.should eq fake_json
      end
    end
  end

  describe "teacher access" do
    before(:each) do
      sign_in teacher.user
      API::V1::Offering.should_receive(:new).and_return(mock_api_offering)
      Portal::Offering.should_receive(:find_by_id).and_return(mock_offering)
      mock_offering.stub_chain(:clazz, :teachers).and_return([teacher])
    end

    describe "GET show" do
      it "renders the show template" do
        get :show, :id => mock_offering_id
        assigns[:offering].should eq mock_api_offering
        response.status.should eq 200
        response.body.should eq fake_json
      end
    end
  end

end
