require File.expand_path('../../spec_helper', __FILE__)

describe SearchController do
  include SolrSpecHelper

  def make(let); end

  let(:admin_settings)   { FactoryBot.create(:admin_settings, :include_external_activities => false) }

  let(:mock_school)     { FactoryBot.create(:portal_school) }

  let(:teacher_user)            { FactoryBot.create(:confirmed_user, :login => "teacher_user") }
  let(:teacher)                 { FactoryBot.create(:portal_teacher, :user => teacher_user, :schools => [mock_school]) }
  let(:admin_user)              { FactoryBot.generate(:admin_user) }
  let(:author_user)             { FactoryBot.generate(:author_user) }
  let(:manager_user)            { FactoryBot.generate(:manager_user) }
  let(:researcher_user)         { FactoryBot.generate(:researcher_user) }

  let(:project)                 { FactoryBot.create(:project) }
  let(:project_admin_user)      {
    project_admin = FactoryBot.generate(:author_user)
    project_admin.admin_for_projects << project
    project_admin
  }
  let(:project_researcher_user) {
    project_admin = FactoryBot.generate(:author_user)
    project_admin.researcher_for_projects << project
    project_admin
  }

  let(:student_user)    { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
  let(:student)         { FactoryBot.create(:portal_student, :user_id => student_user.id) }

  let(:physics_investigation)     { FactoryBot.create(:external_activity, :name => 'physics_inv', :user => author_user, :publication_status => 'published') }
  let(:chemistry_investigation)   { FactoryBot.create(:external_activity, :name => 'chemistry_inv', :user => author_user, :publication_status => 'published') }
  let(:biology_investigation)     { FactoryBot.create(:external_activity, :name => 'mathematics_inv', :user => author_user, :publication_status => 'published') }
  let(:mathematics_investigation) { FactoryBot.create(:external_activity, :name => 'biology_inv', :user => author_user, :publication_status => 'published') }
  let(:lines)                     { FactoryBot.create(:external_activity, :name => 'lines_inv', :user => author_user, :publication_status => 'published') }

  let(:laws_of_motion_activity)  { FactoryBot.create(:external_activity, :name => 'laws_of_motion_activity', :user => author_user) }
  let(:fluid_mechanics_activity) { FactoryBot.create(:external_activity, :name => 'fluid_mechanics_activity', :user => author_user) }
  let(:thermodynamics_activity)  { FactoryBot.create(:external_activity, :name => 'thermodynamics_activity',  :user => author_user) }
  let(:parallel_lines)           { FactoryBot.create(:external_activity, :name => 'parallel_lines', :user => author_user) }

  let(:external_activity1)   { FactoryBot.create(:external_activity, :name => 'external_1', :url => "http://concord.org", :publication_status => 'published', :is_official => true) }
  let(:external_activity2)   { FactoryBot.create(:external_activity, :name => 'a_study_in_lines_and_curves', :url => "http://github.com", :publication_status => 'published', :is_official => true) }

  let(:contributed_activity) { FactoryBot.create(:external_activity, :name => "Copy of external_1", :url => "http://concord.org", :publication_status => 'published', :is_official => false) }

  let(:all_investigations)    { [physics_investigation, chemistry_investigation, biology_investigation, mathematics_investigation, lines]}
  let(:official_activities)   { [laws_of_motion_activity, fluid_mechanics_activity, thermodynamics_activity, parallel_lines, external_activity1, external_activity2]}
  let(:contributed_activities){ [contributed_activity] }
  let(:all_activities)        {  official_activities.concat(contributed_activities) }
  let(:investigation_results) { [] }
  let(:activity_results)      { [] }

  let(:search_results) {{ Investigation => investigation_results, Activity => activity_results }}
  let(:mock_search)    { double('results', {:results => search_results})}

  before(:all) do
    solr_setup
    clean_solar_index
  end

  after(:each) do
    clean_solar_index
  end

  before(:each) do
    admin_settings
    sign_in teacher_user
    make all_investigations
    make official_activities
    make contributed_activities
    make all_activities
    Sunspot.commit_if_dirty
  end

  describe "GET index" do
    describe "when its a student visiting" do
      it "should redirect to student home" do
        student # Ensure student_user has a PortalStudent
        allow(controller).to receive(:current_user).and_return(student_user)
        get :index
        expect(response).to redirect_to("/my_classes")
      end
    end

    describe "when there are no query parameters" do
      it "should redirect to ?include_official=1" do
        get :index
        expect(response).to redirect_to action: :index, include_official: '1'
      end
    end

    describe "when it is a teacher visiting" do
      it "should not show the show archived checkbox" do
        get :index
        expect(assigns(:can_view_archived)).to be_falsey
      end
    end

    describe "should show the archived resources checkbox" do
      it "when the user is an admin" do
        admin_user
        allow(controller).to receive(:current_user).and_return(admin_user)
        get :index
        expect(assigns(:can_view_archived)).to be_truthy
      end
      it "when the user is a researcher" do
        researcher_user
        allow(controller).to receive(:current_user).and_return(researcher_user)
        get :index
        expect(assigns(:can_view_archived)).to be_truthy
      end
      it "when the user is a project admin" do
        project
        project_admin_user
        allow(controller).to receive(:current_user).and_return(project_admin_user)
        get :index
        expect(assigns(:can_view_archived)).to be_truthy
      end
      it "when the user is a project researcher" do
        project
        project_researcher_user
        allow(controller).to receive(:current_user).and_return(project_researcher_user)
        get :index
        expect(assigns(:can_view_archived)).to be_truthy
      end
    end
  end
end
