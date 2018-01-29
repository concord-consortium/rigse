require 'spec_helper'

describe API::V1::ReportLearnersEsController do

  let(:admin_user)        { Factory.next(:admin_user)     }
  let(:simple_user)       { Factory.create(:confirmed_user, :login => "authorized_student") }
  let(:manager_user)      { Factory.next(:manager_user)   }

  let(:search_body)       { {
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
                                        "field" => "permission_forms_id.keyword", "size" => 1000
                                    }
                                }
                              },
                              "query" => {
                                "bool" => {
                                    "filter" => []
                                }
                              }
                          }}
  let(:fake_response)     { {fake:true}.to_json  }


  before (:each) do
    WebMock.stub_request(:post, /report_learners\/_search$/).
      to_return(:status => 200, :body => fake_response, :headers => {})
  end

  describe "anonymous' access" do
    before (:each) do
      logout_user
    end
    describe "GET index" do
      it "wont allow index, returns error 403" do
        get :index
        response.status.should eql(403)
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
        response.status.should eql(403)
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
        response.status.should eql(200)
      end
      it "makes a request to ES with the correct body" do
        get :index
        assert_requested :post, /report_learners\/_search$/,
          headers: {'Content-Type'=>'application/json'},
          body: search_body,
          times: 1
      end
      it "directly renders the ES response" do
        get :index
        response.body.should eq fake_response
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
        response.status.should eql(200)
      end
    end
  end

  describe "project researcher access" do

    before (:each) do
      @project1 = Factory.create(:project)
      @form1 = Factory.create(:permission_form, project: @project1)
      user = Factory.create(:confirmed_user)
      user.add_role_for_project('researcher', @project1)
      sign_in user
    end

    describe "GET index" do
      it "allows index" do
        get :index
        response.status.should eql(200)
      end
      it "makes a request to ES with the correct body, restricting permission forms" do
        get :index

        restricted_search_body = search_body
        restricted_search_body["query"]["bool"]["filter"] = [{
          "terms" => {"permission_forms_id" => [@form1.id]}
        }]
        restricted_search_body["aggs"]["permission_forms_ids"]["terms"]["include"] =
          [@form1.id]

        assert_requested :post, /report_learners\/_search$/,
          headers: {'Content-Type'=>'application/json'},
          body: search_body,
          times: 1
      end
    end
  end

end
