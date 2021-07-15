require 'spec_helper'

describe API::V1::ReportLearnersEsController do

  def set_jwt_bearer_token(auth_token)
    request.headers["Authorization"] = "Bearer/JWT #{auth_token}"
  end

  let(:admin_user)        { FactoryBot.generate(:admin_user)     }
  let(:simple_user)       { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
  let(:manager_user)      { FactoryBot.generate(:manager_user)   }

  let(:district)       { FactoryBot.create(:portal_district) }
  let(:mock_school)    { FactoryBot.create(:portal_school, {:district => district}) }
  let(:teacher_user1)  { FactoryBot.create(:confirmed_user, login: "teacher_user1") }
  let(:teacher_user2)  { FactoryBot.create(:confirmed_user, login: "teacher_user2") }
  let(:teacher1)       { FactoryBot.create(:portal_teacher, user: teacher_user1, schools: [mock_school]) }
  let(:teacher2)       { FactoryBot.create(:portal_teacher, user: teacher_user2, schools: [mock_school]) }
  let(:clazz1)         { FactoryBot.create(:portal_clazz, teachers: [teacher1]) }
  let(:clazz2)         { FactoryBot.create(:portal_clazz, teachers: [teacher1, teacher2]) }
  let(:external_activity) { FactoryBot.create(:external_activity) }
  let(:offering1) { FactoryBot.create(
    :portal_offering,
    runnable_id: external_activity.id,
    runnable_type: 'ExternalActivity',
    clazz: clazz1
  )}
  let(:offering2) { FactoryBot.create(
    :portal_offering,
    runnable_id: external_activity.id,
    runnable_type: 'ExternalActivity',
    clazz: clazz2
  )}

  let(:learner1)          { FactoryBot.create(:full_portal_learner, { offering_id: offering1.id }) }
  let(:learner2)          { FactoryBot.create(:full_portal_learner, { offering_id: offering2.id }) }
  let(:learner3)          { FactoryBot.create(:full_portal_learner) }

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
      },
      "sort" => [
        {
          "created_at" => {
            "order" => "asc"
          }
        },
        {
          "learner_id" => {
            "order" => "asc"
          }
        }
      ]
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
      },
      "sort" => [
        {
          "created_at" => {
            "order" => "asc"
          }
        },
        {
          "learner_id" => {
            "order" => "asc"
          }
        }
      ]
    }
  end

  let(:fake_response) do
    # This is very minimal subset of ES response necessary for Report::Learner::Selector to work.
    {
      hits: {
        hits: [
          {
            _id: learner1.id,
            _source: learner1.elastic_search_learner_model
          },
          {
            _id: learner2.id,
            _source: learner2.elastic_search_learner_model
          },
          {
            _id: learner3.id,
            _source: learner3.elastic_search_learner_model
          }
        ]
      }
    }.to_json
  end


  before (:each) do
    # This silences warnings in the console when running
    generate_default_settings_and_jnlps_with_mocks

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
      let(:url_for_user) { "http://test.host/users/#{admin_user.id}" } # can't use url_for(user) helper in specs

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
        expect(filter["version"]).to eq "1.1"
        expect(filter["learners"].length).to eq 3
        expect(filter["learners"][0]["run_remote_endpoint"]).to eq learner1.remote_endpoint_url
        expect(filter["learners"][0]["class_id"]).to eq learner1.offering.clazz_id
        expect(filter["learners"][0]["runnable_url"]).to eq external_activity.url # not nil because it is an external activity
        expect(filter["learners"][1]["run_remote_endpoint"]).to eq learner2.remote_endpoint_url
        expect(filter["learners"][1]["class_id"]).to eq learner2.offering.clazz_id
        expect(filter["learners"][2]["runnable_url"]).to eq nil  # nil because it is in investigation
        expect(filter["user"]["id"]).to eq url_for_user
        expect(filter["user"]["email"]).to eq admin_user.email

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

  describe "external_report_query_jwt" do

    describe "anonymous' access" do
      before (:each) do
        logout_user
      end
      describe "GET external_report_query_jwt" do
        it "wont allow external_report_query_jwt, returns error 403" do
          get :external_report_query_jwt
          expect(response.status).to eql(403)
        end
      end
    end

    describe "simple user access" do
      before (:each) do
        sign_in simple_user
      end
      describe "GET external_report_query_jwt" do
        it "wont allow external_report_query_jwt, returns error 403" do
          get :external_report_query_jwt
          expect(response.status).to eql(403)
        end
      end
    end

    describe "admin access" do
      before (:each) do
        sign_in admin_user
      end
      describe "GET external_report_jwt_query" do

        it "renders response that includes Log Manager query and JWT" do
          get :external_report_query_jwt
          resp = JSON.parse(response.body)
          filter = resp["json"]
          expect(filter["type"]).to eq "learners"
          expect(filter["query"]).not_to eq nil
          expect(filter["learnersApiUrl"]).to eq "http://test.host/api/v1/report_learners_es/external_report_learners_from_jwt"
          expect(resp["token"]).to be_an_instance_of(String)
          expect(resp["signature"]).to eq nil
        end
      end
    end

    describe "manager access" do
      before (:each) do
        sign_in manager_user
      end
      describe "GET external_report_query_jwt" do
        it "allows external_report_query_jwt" do
          get :external_report_query_jwt
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

      describe "GET external_report_query_jwt" do
        it "allows external_report_query_jwt" do
          get :external_report_query_jwt
          expect(response.status).to eql(200)
        end
      end
    end

  end

  describe "external_report_learners_from_jwt" do

    before (:each) do
      logout_user
    end

    describe "without a JWT" do
      describe "GET external_report_learners_from_jwt" do
        it "wont allow external_report_learners_from_jwt, returns error 403" do
          get :external_report_learners_from_jwt
          expect(response.status).to eql(403)
        end
      end
    end

    describe "simple user access" do
      before (:each) do
        jwt = SignedJWT::create_portal_token(simple_user, {}, 3600)
        set_jwt_bearer_token(jwt)
      end

      describe "GET external_report_learners_from_jwt" do
        it "wont allow external_report_learners_from_jwt, returns error 403" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          expect(response.status).to eql(403)
        end
      end
    end

    describe "admin access" do
      before (:each) do
        jwt = SignedJWT::create_portal_token(admin_user, {}, 3600)
        set_jwt_bearer_token(jwt)
      end

      describe "GET external_report_learners_from_jwt" do

        it "renders response that includes learners" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          resp = JSON.parse(response.body)
          filter = resp["json"]
          expect(filter["learners"].length).to eq 3
          expect(filter["learners"][0]["student_id"].to_i).to be_an_instance_of(Fixnum)
          expect(filter["learners"][0]["learner_id"].to_i).to eq learner1.id
          expect(filter["learners"][0]["student_name"]).to eq learner1.user.name
          expect(filter["learners"][0]["username"]).to eq learner1.user.login
          expect(filter["learners"][0]["class_id"].to_i).to eq clazz1.id
          expect(filter["learners"][0]["teachers"]).to be_an_instance_of(Array)
          expect(filter["learners"][0]["teachers"].length).to eq 1
          expect(filter["learners"][1]["teachers"].length).to eq 2    # learner2's class has two teachers
          expect(filter["learners"][1]["teachers"][0]["user_id"].to_i).to eq teacher2.id
          expect(filter["learners"][1]["teachers"][1]["user_id"].to_i).to eq teacher1.id
        end
      end

      describe "GET external_report_learners_from_jwt with incorrect page_size" do

        it "renders an error if page_size is missing" do
          get :external_report_learners_from_jwt, {:query => {}}
          expect(response.status).to eql(400)
        end
        it "renders an error if page_size is too large" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 10000}
          expect(response.status).to eql(400)
        end

      end

      describe "GET external_report_learners_from_jwt with elastic search error" do
        let(:fake_error_response) do
          # This is a guess about what an ES error might look like
          {
            error: "Fake ES Error"
          }.to_json
        end

        before(:each) do
          WebMock.stub_request(:post, /report_learners\/_search$/).
            to_return(:status => 500, :body => fake_error_response,
              :headers => { "Content-Type" => "application/json" })
        end

        it "renders the error returned by ES" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          resp = JSON.parse(response.body)
          expect(resp['message']).to eql("Elastic Search Error")
          expect(resp['details']['response_body']).to eql(fake_error_response)
          expect(response.status).to eql(500)
        end

      end

      describe "GET external_report_learners_from_jwt with no hits" do
        let(:fake_response) do
          # This is a guess about what the response will look like with no matches
          {
            hits: {
              hits: []
            }
          }.to_json
        end

        it "renders an empty list of learners" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          expect(response.status).to eql(200)
          resp = JSON.parse(response.body)
          filter = resp["json"]
          expect(filter["learners"].length).to eq 0
          expect(filter["lastHitSortValue"]).to eq nil
        end

      end
    end

    describe "manager access" do
      before (:each) do
        jwt = SignedJWT::create_portal_token(manager_user, {}, 3600)
        set_jwt_bearer_token(jwt)
      end

      describe "GET external_report_learners_from_jwt" do
        it "allows external_report_learners_from_jwt" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
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

        jwt = SignedJWT::create_portal_token(user, {}, 3600)
        set_jwt_bearer_token(jwt)
      end

      describe "GET external_report_learners_from_jwt" do
        it "allows external_report_learners_from_jwt" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          expect(response.status).to eql(200)
        end
      end
    end

    describe "school without district" do
      before (:each) do
        jwt = SignedJWT::create_portal_token(admin_user, {}, 3600)
        set_jwt_bearer_token(jwt)
      end

      describe "GET external_report_learners_from_jwt" do

        it "renders response that includes learners" do
          get :external_report_learners_from_jwt, {:query => {}, :page_size => 1000}
          resp = JSON.parse(response.body)
          filter = resp["json"]
          expect(filter["learners"].length).to eq 3
          expect(filter["learners"][0]["teachers"]).to be_an_instance_of(Array)
          expect(filter["learners"][0]["teachers"].length).to eq 1
          expect(filter["learners"][0]["teachers"][0]["user_id"].to_i).to eq teacher1.id
          expect(filter["learners"][0]["teachers"][0]["district"]).to eq "Rails Portal-district"
        end
      end
    end

  end
end
