require 'spec_helper'

describe API::V1::ExternalActivitiesController do

  let(:admin_user)        { FactoryBot.generate(:admin_user)      }
  let(:simple_user)       { FactoryBot.create(:confirmed_user)    }
  let(:manager_user)      { FactoryBot.generate(:manager_user)    }
  let(:researcher_user)   { FactoryBot.generate(:researcher_user) }
  let(:author_user)       { FactoryBot.generate(:author_user)     }

  describe "#create" do
    context "with a guest" do
      before (:each) do
        logout_user
      end

      it "fails with valid parameters" do
        post :create, params: { :name => "test", :url => "http://example.com/" }
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in simple user" do
      before (:each) do
        sign_in simple_user
      end

      it "fails with valid parameters" do
        post :create, params: { :name => "test", :url => "http://example.com/" }
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in manager user" do
      before (:each) do
        sign_in manager_user
      end

      it "succeeds with valid parameters" do
        post :create, params: { :name => "test", :url => "http://example.com/" }
        expect(response.status).to eql(201)
      end
    end

    context "with a logged in researcher user" do
      before (:each) do
        sign_in researcher_user
      end

      it "succeeds with valid parameters" do
        post :create, params: { :name => "test", :url => "http://example.com/" }
        expect(response.status).to eql(201)
      end
    end

    context "with a logged in author user" do
      before (:each) do
        sign_in author_user
      end

      it "succeeds with valid minimal parameters" do
        post :create, params: {:name => "test", :url => "http://example.com/"}
        expect(response.status).to eql(201)
      end
    end

    context "with a logged in admin user" do
      before (:each) do
        sign_in admin_user
      end

      it "fails with a missing name parameter" do
        post :create, params: { :url => "http://example.com/" }
        expect(response.status).to eql(400)
      end

      it "fails with a missing url parameter" do
        post :create, params: {:name => "test"}
        expect(response.status).to eql(400)
      end

      it "fails with an invalid url parameter" do
        post :create, params: { :url => "invalid" }
        expect(response.status).to eql(400)
      end

      it "succeeds with valid minimal parameters" do
        post :create, params: { :name => "test", :url => "http://example.com/" }
        expect(response.status).to eql(201)
      end
    end
  end

  describe "#update_basic" do
    let(:valid_attributes) { {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :long_description => "value for description",
      :long_description_for_teacher => "value for description for teachers",
      :publication_status => "value for publication_status",
      :is_featured => true,
      :is_official => true,
      :logging => true,
      :url => "http://www.concord.org/"
    } }
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let (:valid_parameters) { {
      id: activity.id,
      publication_status: "draft",
      grade_levels: ["1", "2"],
      subject_areas: "Math",
      sensors: "Temperature"
    } }

    context "with a guest" do
      before (:each) do
        logout_user
      end

      it "fails with valid parameters" do
        post :update_basic, params: valid_parameters
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in simple user" do
      before (:each) do
        sign_in simple_user
      end

      it "fails with valid parameters" do
        post :update_basic, params: valid_parameters
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in manager user" do
      before (:each) do
        sign_in manager_user
      end

      it "succeeds with valid parameters" do
        post :update_basic, params: valid_parameters
        expect(response.status).to eql(200)
      end
    end

    context "with a logged in admin user" do
      before (:each) do
        sign_in admin_user
      end

      it "succeeds with valid parameters" do
        post :update_basic, params: valid_parameters
        expect(response.status).to eql(200)
      end
    end
  end

  describe "#update_by_url" do
    let(:url ) { "http://activity.com/activity/1" }
    let(:valid_attributes) do
      {
        "name" => "Cool Activity",
        "url" => url,
        "author_url" => "#{url}/edit",
        "launch_url" => "#{url}/1/sessions/",
        "student_report_enabled" => true,
        "thumbnail_url" => "/path/to/thumbnail",
        "is_locked" => false,
        "append_auth_token" => true,
        "publication_status" => "private"
      }
    end
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let (:valid_parameters) { {
      url: activity.url
    } }

    context "with a guest" do
      before (:each) do
        logout_user
      end

      it "fails with valid parameters" do
        post :update_by_url, params: valid_parameters
        expect(response.status).to eql(403)
      end
    end

    context "with a logged in author user" do
      before (:each) do
        sign_in author_user
      end

      it "should not update an activity they did not author" do
        post :update_by_url, params: valid_parameters
        expect(response.status).to eql(403)
      end

      it "should update an activity they did author" do
        my_url = "http://activity.com/activity/2"
        post :create, params: {:name => "My Cool Activity", :url => my_url}
        my_valid_parameters = {
          url: my_url
        }
        post :update_by_url, params: my_valid_parameters
        expect(response.body).to eql('{"success":true}')
      end
    end

    context "with a logged in admin user" do
      before (:each) do
        sign_in admin_user
      end

      it "should update the activity" do
        post :update_by_url, params: valid_parameters
        expect(response.body).to eql('{"success":true}')
      end
    end
  end
end
