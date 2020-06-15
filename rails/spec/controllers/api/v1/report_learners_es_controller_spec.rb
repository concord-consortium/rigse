require 'spec_helper'

describe API::V1::ReportLearnersEsController do

  let(:admin_user)        { FactoryBot.generate(:admin_user)     }
  let(:simple_user)       { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
  let(:manager_user)      { FactoryBot.generate(:manager_user)   }

  let(:learner1)          { FactoryBot.create(:full_portal_learner) }
  let(:learner2)          { FactoryBot.create(:full_portal_learner) }

  let(:index_search_body) do
    {
      "size" => 0,
      "aggs" => {
        "count_students" => {
          "cardinality" => {
            "field" => "student_id"
          }
        }, "count_classes" => {
          "cardinality" => {
            "field" => "class_id"
          }
        }, "count_teachers" => {
          "cardinality" => {
            "field" => "teachers_map.keyword"
          }
        }, "count_runnables" => {
          "cardinality" => {
            "field" => "runnable_id"
          }
        }, "schools" => {
          "terms" => {
            "field" => "school_name_and_id.keyword", "size" => 1000
          }
        }, "teachers" => {
          "terms" => {
            "field" => "teachers_map.keyword", "size" => 500
          }
        }, "runnables" => {
          "terms" => {
            "field" => "runnable_type_id_name.keyword", "size" => 1000
          }
        }, "permission_forms" => {
          "terms" => {
            "field" => "permission_forms_map.keyword", "size" => 1000
          }
        }, "permission_forms_ids" => {
          "terms" => {
            "field" => "permission_forms_id", "size" => 1000
          }
        }
      },
      "query" => {
        "bool" => {
          "filter" => []
        }
      }
    }
  end

  let(:external_report_query_search_body) do
    {
      "size" => 5000,
      "aggs" => {},
      "query" => {
        "bool" => {
          "filter" => []
        }
      }
    }
  end

  let(:fake_response) do
    # This is very minimal subset of ES response necessary for Report::Learner::Selector to work.
    {
      hits: {
        hits: [
          {
            _id: learner1.report_learner.id,
            _source: {
              runnable_type_and_id: 'externalactivity_1',
            }
          },
          {
            _id: learner2.report_learner.id,
            _source: {
              runnable_type_and_id: 'externalactivity_2',
            }
          }
        ]
      }
    }.to_json
  end


  before (:each) do
    WebMock.stub_request(:post, /report_learners\/_search$/).
      to_return(:status => 200, :body => fake_response, :headers => { "Content-Type" => "application/json" })
  end

  describe "anonymous' access" do
    before (:each) do
      logout_user
    end
    describe "GET index" do
      it "wont allow index, returns error 403" do
        get :index
        expect(response.status).to eql(403)
      end
    end
    describe "GET external_report_query" do
      it "wont allow external_report_query, returns error 403" do
        get :external_report_query
        expect(response.status).to eql(403)
      end
    end
  end

  describe "simple user access" do
    before (:each) do
      sign_in simple_user
    end
    describe "GET index" do
      it "wont allow index, returns error 403" do
        get :index
        expect(response.status).to eql(403)
      end
    end
    describe "GET external_report_query" do
      it "wont allow external_report_query, returns error 403" do
        get :external_report_query
        expect(response.status).to eql(403)
      end
    end
  end

  describe "admin access" do
    before (:each) do
      sign_in admin_user
    end
    describe "GET index" do
      it "allows index" do
        get :index
        expect(response.status).to eql(200)
      end
      it "makes a request to ES with the correct body" do
        get :index
        expect(WebMock).to have_requested(:post, /report_learners\/_search$/).
          with(
            headers: {'Content-Type'=>'application/json'},
            body: index_search_body,
          ).times(1)
      end
      it "directly renders the ES response" do
        get :index
        expect(response.body).to eq fake_response
      end
    end
    describe "GET external_report_query" do
      it "allows index" do
        get :external_report_query
        expect(response.status).to eql(200)
      end
      it "makes a request to ES with the correct body" do
        get :external_report_query
        expect(WebMock).to have_requested(:post, /report_learners\/_search$/).
          with(
            headers: {'Content-Type'=>'application/json'},
            body: external_report_query_search_body,
          ).times(1)
      end
      it "renders response that includes Log Manager query and signature" do
        get :external_report_query
        resp = JSON.parse(response.body)
        filter = resp["json"]
        expect(filter["type"]).to eq "learners"
        expect(filter["version"]).to eq "1.0"
        expect(filter["learners"].length).to eq 2
        expect(filter["learners"][0]["run_remote_endpoint"]).to eq learner1.remote_endpoint_url
        expect(filter["learners"][0]["class_id"]).to eq learner1.offering.clazz_id
        expect(filter["learners"][1]["run_remote_endpoint"]).to eq learner2.remote_endpoint_url
        expect(filter["learners"][1]["class_id"]).to eq learner2.offering.clazz_id

        expect(resp["signature"]).to eq OpenSSL::HMAC.hexdigest("SHA256", SignedJWT.hmac_secret, resp["json"].to_json)
      end
    end
  end

  describe "manager access" do
    before (:each) do
      sign_in manager_user
    end
    describe "GET index" do
      it "allows index" do
        get :index
        expect(response.status).to eql(200)
      end
    end
    describe "GET external_report_query" do
      it "allows external_report_query" do
        get :external_report_query
        expect(response.status).to eql(200)
      end
    end
  end

  describe "project researcher access" do

    before (:each) do
      @project1 = FactoryBot.create(:project)
      @form1 = FactoryBot.create(:permission_form, project: @project1)
      user = FactoryBot.create(:confirmed_user)
      user.add_role_for_project('researcher', @project1)
      sign_in user
    end

    describe "GET index" do
      it "allows index" do
        get :index
        expect(response.status).to eql(200)
      end
      it "makes a request to ES with the correct body, restricting permission forms" do
        get :index

        restricted_search_body = index_search_body
        restricted_search_body["query"]["bool"]["filter"] = [{
          "terms" => {"permission_forms_id" => [@form1.id]}
        }]
        restricted_search_body["aggs"]["permission_forms_ids"]["terms"]["include"] =
          [@form1.id]

        expect(WebMock).to have_requested(:post, /report_learners\/_search$/).
          with(
            headers: {'Content-Type'=>'application/json'},
            body: restricted_search_body,
          ).times(1)
      end
    end

    describe "GET external_report_query" do
      it "allows external_report_query" do
        get :external_report_query
        expect(response.status).to eql(200)
      end
      it "makes a request to ES with the correct body, restricting permission forms" do
        get :external_report_query

        restricted_search_body = external_report_query_search_body
        restricted_search_body["query"]["bool"]["filter"] = [{
          "terms" => {"permission_forms_id" => [@form1.id]}
        }]

        expect(WebMock).to have_requested(:post, /report_learners\/_search$/).
          with(
            headers: {'Content-Type'=>'application/json'},
            body: restricted_search_body,
          ).times(1)
      end
    end
  end

end
