require 'spec_helper'

describe API::V1::ReportUsersController do

  let(:admin_user)        { FactoryBot.generate(:admin_user)     }
  let(:simple_user)       { FactoryBot.create(:confirmed_user, :login => "authorized_student") }

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
      @teacher1 = FactoryBot.create(:portal_teacher)
      @teacher2 = FactoryBot.create(:portal_teacher)
      @teacher3 = FactoryBot.create(:portal_teacher)
      @teacher4 = FactoryBot.create(:portal_teacher)
      @teacher5 = FactoryBot.create(:portal_teacher)
      @teacher6 = FactoryBot.create(:portal_teacher)

      @cohort1 = FactoryBot.create(:admin_cohort)
      @cohort2 = FactoryBot.create(:admin_cohort)

      @teacher3.cohorts << @cohort1
      @teacher4.cohorts << @cohort1
      @teacher5.cohorts << @cohort2

      @runnable1 = FactoryBot.create(:external_activity)
      @runnable2 = FactoryBot.create(:external_activity)
      @runnable3 = FactoryBot.create(:external_activity)

      @offering1 = FactoryBot.create(:portal_offering, {clazz: @teacher1.clazzes[0], runnable: @runnable1})
      @offering2 = FactoryBot.create(:portal_offering, {clazz: @teacher2.clazzes[0], runnable: @runnable2})
      @offering3 = FactoryBot.create(:portal_offering, {clazz: @teacher3.clazzes[0], runnable: @runnable3})

      sign_in admin_user
    end
    describe "GET index" do
      it "allows index" do
        get :index, {
          teachers: "#{@teacher1.id},#{@teacher2.id}",
          runnables: "#{@runnable1.id},#{@runnable2.id},#{@runnable3.id}",
          cohorts: "#{@cohort1.id},#{@cohort2.id}",
          start_date: "01/02/19",
          end_date: "03/04/19"
        }
        expect(response.status).to eql(200)
      end
      it "gets totals" do
        get :index, {
          totals: "true",
          remove_cc_teachers: true
        }
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json).to eql({"totals"=>{"cohorts"=>2, "runnables"=>3, "teachers"=>6}})
      end
      it "gets all teachers" do
        get :index, { load_all: "teachers" }
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["teachers"].length).to eql(6)
      end
      it "gets all cohorts" do
        get :index, { load_all: "cohorts" }
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["cohorts"].length).to eql(2)
      end
      it "gets all runnables" do
        get :index, { load_all: "runnables" }
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["runnables"].length).to eql(3)
      end
    end
    describe "GET external_report_query" do
      before(:each) do
        @old_configuration = APP_CONFIG[:site_url]
        APP_CONFIG[:site_url] = 'http://example.com'
      end

      after(:each) do
        APP_CONFIG[:site_url] = @old_configuration
      end

      it "allows index" do
        get :external_report_query
        expect(response.status).to eql(200)
      end
      it "renders response that includes Log Manager query and signature" do
        get :external_report_query, {
          teachers: "#{@teacher1.id},#{@teacher2.id}",
          runnables: "#{@runnable1.id},#{@runnable2.id},#{@runnable3.id}",
          cohorts: "#{@cohort1.id},#{@cohort2.id}",
          start_date: "01/02/19",
          end_date: "03/04/19"
        }
        resp = JSON.parse(response.body)
        filter = resp["json"]
        expect(filter["type"]).to eq "users"
        expect(filter["version"]).to eq "1.0"
        expect(filter["domain"]).to eq "example.com"
        expect(filter["users"].length).to eq 5
        expect(filter["runnables"].length).to eq 3
        expect(filter["start_date"]).to eq "01/02/19"
        expect(filter["end_date"]).to eq "03/04/19"
        expect(resp["signature"]).to eq OpenSSL::HMAC.hexdigest("SHA256", SignedJWT.hmac_secret, resp["json"].to_json)
      end
    end
  end

  describe "project admin access" do

    before (:each) do
      project = FactoryBot.create(:project)
      user = FactoryBot.create(:confirmed_user)
      user.add_role_for_project('admin', project)
      sign_in user
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
      project = FactoryBot.create(:project)
      user = FactoryBot.create(:confirmed_user)
      user.add_role_for_project('researcher', project)
      sign_in user
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

end
