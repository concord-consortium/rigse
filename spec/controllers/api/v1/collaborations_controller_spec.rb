# encoding: utf-8
require 'spec_helper'

def set_request_header(key,value)
  request.env[key] = value
end

def set_auth_token(auth_token)
  set_request_header("Authorization", "Bearer #{auth_token}" )
end

describe API::V1::CollaborationsController do
  let(:student1) { Factory(:full_portal_student) }
  let(:student2) { Factory(:full_portal_student) }
  let(:offering) do
    offering = Factory(:portal_offering)
    clazz = offering.clazz
    clazz.students = [student1, student2]
    clazz.save!
    offering
  end
  let(:clazz) { offering.clazz }
  let(:params) do
    {
      'offering_id' => offering.id,
      'owner_id' => student1.id,
      'students' => [
        {
          'id' => student1.id,
          'password' => 'password' # this is valid password, see users factory.
        },
        {
          'id' => student2.id,
          'password' => 'password'
        }
      ]
    }
  end

  describe "POST #create" do
    context "with valid attributes and student is signed in" do
      before { sign_in student1.user }

      it "creates a new collaboration" do
        expect(Portal::Collaboration.count).to eql(0)
        post :create, params
        expect(response.status).to eq(201) # created
        expect(JSON.parse(response.body)["id"]).to eql(Portal::Collaboration.first.id)
        expect(Portal::Collaboration.first.owner.id).to eql(params['owner_id'])
      end
    end

    context "when no user is signed in" do
      it "returns an error" do
        expect(Portal::Collaboration.count).to eql(0)
        post :create, params
        expect(response.status).to eq(401) # unauthorized
        expect(Portal::Collaboration.count).to eql(0)
      end
    end

    context "when teacher is signed in" do
      before do
        teacher = Factory(:portal_teacher)
        sign_in teacher.user
      end

      it "returns an error" do
        expect(Portal::Collaboration.count).to eql(0)
        post :create, params
        expect(response.status).to eq(401) # unauthorized
        expect(Portal::Collaboration.count).to eql(0)
      end
    end
  end

  describe "GET #available_collaborators" do
    context "when no user is signed in" do
      it "returns an error" do
        get :available_collaborators, offering_id: offering.id
        expect(response.status).to eq(401) # unauthorized
      end
    end

    context "when class member is signed in" do
      before { sign_in student1.user }

      it "returns students list" do
        get :available_collaborators, offering_id: offering.id
        expect(response.status).to eq(200)
        # Note that we do not expect student1 in the list!
        expected_collaborators = [student2].map { |s| {'id' => s.id, 'name' => s.name} }
        expect(JSON.parse(response.body)).to match_array(expected_collaborators)
      end
    end
  end

  describe "GET #collaborators_data" do
    let(:lara_token)   { 'xyzzy'                            }
    let(:clients)      { [ mock(:app_secret => lara_token)] }
    before(:each)      { Client.stub(:all => clients)       }
  
    before do
      sign_in student1.user
      post :create, params
      expect(response.status).to eq(201)
      sign_out :user
      @collaboration_id = JSON.parse(response.body)["id"]
    end

    context "when no authentication header token is sent" do
      it "returns an error" do
        get :collaborators_data, id: @collaboration_id
        expect(response.status).to eq(401) # unauthorized
      end
    end

    context "when a valid authentication header token is sent" do
      let(:security_header_sent) { lara_token }

      it "returns list of student data and endpoints" do
        set_auth_token(security_header_sent)
        get :collaborators_data, {id: @collaboration_id}
        expect(response.status).to eq(200)
      end
    end

    context "when a non-valid authentication header token is sent" do
      let(:security_header_sent) { "bogusvalue" }

      it "returns an error" do
        set_auth_token(security_header_sent)
        get :collaborators_data, {id: @collaboration_id}
        expect(response.status).to eq(401)
      end
    end

  end

end
