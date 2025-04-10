require 'spec_helper'

describe API::V1::ResearchClassesController do

  before(:each) {
    # This silences warnings in the console when running
    generate_default_settings_with_mocks
  }

  before (:each) do
    @cc_school = FactoryBot.create(:portal_school, {name: 'concord consortium'})

    @teacher1 = FactoryBot.create(:portal_teacher, schools: [@cc_school])
    @teacher2 = FactoryBot.create(:portal_teacher, schools: [@cc_school])

    @project1 = FactoryBot.create(:project, name: 'Project 1', landing_page_slug: 'project-1')
    @project2 = FactoryBot.create(:project, name: 'Project 2', landing_page_slug: 'project-2')

    @cohort1 = FactoryBot.create(:admin_cohort, project: @project1)
    @cohort2 = FactoryBot.create(:admin_cohort, project: @project2)

    @teacher1.cohorts << @cohort1
    @teacher2.cohorts << @cohort2

    @clazz1 = @teacher1.clazzes[0]
    @clazz2 = @teacher2.clazzes[0]

    @runnable1 = FactoryBot.create(:external_activity)
    @runnable2 = FactoryBot.create(:external_activity)

    @offering1 = FactoryBot.create(:portal_offering, {clazz: @clazz1, runnable: @runnable1})
    @offering2 = FactoryBot.create(:portal_offering, {clazz: @clazz2, runnable: @runnable2})

    # This line is very important because it protects against regressions related to the following issue:
    # https://www.pivotaltracker.com/story/show/187422622
    # @clazz1 is now considered valid for both @project1 and @project2 (via @teacher2 and @cohort2).
    # This will test explicit filtering of filter options (cohorts, teachers, runnables) by project_id.
    @clazz1.teachers << @teacher2

    sign_in researcher
  end

  let(:researcher) do
    user = FactoryBot.create(:confirmed_user)
    user.add_role_for_project('researcher', @project1)
    user.add_role_for_project('researcher', @project2)
    user
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
  end

  describe "simple user access" do
    let(:simple_user) { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
    before (:each) do
      sign_in simple_user
    end
    describe "GET index" do
      it "wont allow index, returns error 403" do
        get :index
        expect(response.status).to eql(403)
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
  end

  describe "project researcher access" do
    before (:each) do
      sign_in researcher
    end

    describe "GET index" do
      it "allows index" do
        get :index
        expect(response.status).to eql(200)
      end
    end
  end

  describe "basic query" do
    describe "GET index" do
      it "allows index" do
        params = {
          project_id: @project1.id
        }
        get :index, params: params
        expect(response.status).to eql(200)
      end
      it "gets class info" do
        params = {
          project_id: @project1.id
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        clazz = @clazz1
        expect(json["hits"]).to eql({"classes"=>[{"class_url"=>materials_portal_clazz_url(clazz.id, researcher: true, host: 'test.host'), "cohort_names"=>@cohort1.name, "id"=>clazz.id, "name"=>clazz.name, "school_name"=>@teacher1.school.name, "teacher_names"=>"#{@teacher1.name}, #{@teacher2.name}"}]})
      end
      it "gets totals" do
        params = {
          project_id: @project1.id
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["totals"]).to eql({"classes"=>1, "cohorts"=>1, "runnables"=>1, "teachers"=>1})
      end
      it "gets all teachers" do
        params = {
          project_id: @project1.id,
          load_only: "teachers"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["teachers"].length).to eql(1)
      end
      it "gets all cohorts" do
        params = {
          project_id: @project1.id,
          load_only: "cohorts"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["cohorts"].length).to eql(1)
        expect(json["hits"]["cohorts"][0]).to eql({"id"=>@cohort1.id, "label"=>"Project 1: test cohort"})
      end
      it "gets all runnables" do
        params = {
          project_id: @project1.id,
          load_only: "runnables"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["runnables"].length).to eql(1)
      end
      it "filters out archived runnables" do
        @runnable1.update_attribute(:is_archived, true)
        params = {
          project_id: @project1.id,
          load_only: "runnables"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["runnables"].length).to eql(0)
      end
      it "filters out CC teachers from teachers results (when requested)" do
        params = {
          project_id: @project1.id,
          load_only: "teachers",
          remove_cc_teachers: "true"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["teachers"].length).to eql(0)
      end
      it "filters out CC teachers from classes results (when requested)" do
        params = {
          project_id: @project1.id,
          remove_cc_teachers: "true"
        }
        get :index, params: params
        json = JSON.parse(response.body)
        expect(response.status).to eql(200)
        expect(json["hits"]["classes"].length).to eql(0)
      end
    end
  end
end
