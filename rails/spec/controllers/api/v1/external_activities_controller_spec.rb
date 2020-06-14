require 'spec_helper'

describe API::V1::ExternalActivitiesController do

  let(:admin_user)        { FactoryBot.generate(:admin_user)     }
  let(:simple_user)       { FactoryBot.create(:confirmed_user) }
  let(:manager_user)      { FactoryBot.generate(:manager_user)   }
  let(:researcher_user)   { FactoryBot.generate(:researcher_user)   }

  describe "#create" do
    context "with a guest" do
      before (:each) do
        logout_user
      end

      it "fails with valid parameters" do
        post :create, :name => "test", :url => "http://example.com/"
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in simple user" do
      before (:each) do
        sign_in simple_user
      end

      it "fails with valid parameters" do
        post :create, :name => "test", :url => "http://example.com/"
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in manager user" do
      before (:each) do
        sign_in manager_user
      end

      it "succeeds with valid parameters" do
        post :create, :name => "test", :url => "http://example.com/"
        expect(response.status).to eql(201)
      end
    end

    context "with a logged in researcher user" do
      before (:each) do
        sign_in researcher_user
      end

      it "succeeds with valid parameters" do
        post :create, :name => "test", :url => "http://example.com/"
        expect(response.status).to eql(201)
      end
    end

    context "with a logged in admin user" do
      before (:each) do
        sign_in admin_user
      end

      it "fails with a missing name parameter" do
        post :create, :url => "http://example.com/"
        expect(response.status).to eql(400)
      end

      it "fails with a missing url parameter" do
        post :create, :url => "http://example.com/"
        expect(response.status).to eql(400)
      end

      it "fails with an invalid url parameter" do
        post :create, :url => "invalid"
        expect(response.status).to eql(400)
      end

      it "succeeds with valid minimal parameters" do
        post :create, :name => "test", :url => "http://example.com/"
        expect(response.status).to eql(201)
      end
    end
  end
end
