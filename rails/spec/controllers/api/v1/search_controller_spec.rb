require 'spec_helper'

describe API::V1::SearchController do
  include SolrSpecHelper

  def make(let); end

  let(:admin_settings)   { FactoryBot.create(:admin_settings, :include_external_activities => false) }

  let(:mock_school)     { FactoryBot.create(:portal_school) }

  let(:teacher_user)    { FactoryBot.create(:confirmed_user, :login => "teacher_user") }
  let(:teacher)         { FactoryBot.create(:portal_teacher, :user => teacher_user, :schools => [mock_school]) }
  let(:teacher_user_2)  { FactoryBot.create(:confirmed_user, :login => "teacher_user_2") }
  let(:teacher_2)       { FactoryBot.create(:portal_teacher, :user => teacher_user_2, :schools => [mock_school]) }
  let(:admin_user)      { FactoryBot.generate(:admin_user) }
  let(:author_user)     { FactoryBot.generate(:author_user) }
  let(:manager_user)    { FactoryBot.generate(:manager_user) }
  let(:researcher_user) { FactoryBot.generate(:researcher_user) }

  let(:student_user)    { FactoryBot.create(:confirmed_user, :login => "authorized_student") }
  let(:student)         { FactoryBot.create(:portal_student, :user_id => student_user.id) }

  let(:physics_investigation)     { FactoryBot.create(:investigation, :name => 'physics_inv', :user => author_user, :publication_status => 'published') }
  let(:chemistry_investigation)   { FactoryBot.create(:investigation, :name => 'chemistry_inv', :user => author_user, :publication_status => 'published') }
  let(:biology_investigation)     { FactoryBot.create(:investigation, :name => 'mathematics_inv', :user => author_user, :publication_status => 'published') }
  let(:mathematics_investigation) { FactoryBot.create(:investigation, :name => 'biology_inv', :user => author_user, :publication_status => 'published') }
  let(:lines)                     { FactoryBot.create(:investigation, :name => 'lines_inv', :user => author_user, :publication_status => 'published') }

  let(:laws_of_motion_activity)  { FactoryBot.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => physics_investigation.id, :user => author_user) }
  let(:fluid_mechanics_activity) { FactoryBot.create(:activity, :name => 'fluid_mechanics_activity' , :investigation_id => physics_investigation.id, :user => author_user) }
  let(:thermodynamics_activity)  { FactoryBot.create(:activity, :name => 'thermodynamics_activity' , :investigation_id => physics_investigation.id, :user => author_user) }
  let(:parallel_lines)           { FactoryBot.create(:activity, :name => 'parallel_lines' , :investigation_id => lines.id, :user => author_user) }

  let(:external_activity1)   { FactoryBot.create(:external_activity,
                                        :name => 'external_1',
                                        :url => "http://concord.org",
                                        :publication_status => 'published',
                                        :is_official => true,
                                        :material_type => 'Activity' ) }

  let(:external_activity2)   { FactoryBot.create(:external_activity,
                                        :name => 'a_study_in_lines_and_curves',
                                        :url => "http://github.com",
                                        :publication_status =>
                                        'published',
                                        :is_official => true,
                                        :material_type => 'Activity' ) }


  let(:external_activity3)   { FactoryBot.create(:external_activity,
                                        :name => 'a_study_in_lines_and_curves',
                                        :url => "http://github.com",
                                        :publication_status =>
                                        'published',
                                        :is_official => true,
                                        :material_type => 'Investigation' ) }


  let(:contributed_activity) { FactoryBot.create(:external_activity,
                                        :name => "Copy of external_1",
                                        :url => "http://concord.org",
                                        :publication_status => 'published',
                                        :is_official => false,
                                        :material_type => 'Activity' ) }

  let(:user_contributed_activity) { FactoryBot.create(:external_activity,
                                        :name => "Copy of external_1",
                                        :url => "http://concord.org",
                                        :publication_status => 'published',
                                        :is_official => false,
                                        :material_type => 'Activity',
                                        :user_id => teacher_user.id ) }

  let(:all_investigations)          { [physics_investigation, chemistry_investigation, biology_investigation, mathematics_investigation, lines, external_activity3]}
  let(:official_activities)         { [laws_of_motion_activity, fluid_mechanics_activity, thermodynamics_activity, parallel_lines, external_activity1, external_activity2]}
  let(:contributed_activities)      { [contributed_activity] }
  let(:user_contributed_activities) { [user_contributed_activity] }
  let(:all_activities)              {  official_activities.concat(contributed_activities).concat(user_contributed_activities) }
  let(:investigation_results)       { [] }
  let(:activity_results)            { [] }

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
    make user_contributed_activities
    make all_activities
    Sunspot.commit_if_dirty
  end

  describe "GET search" do

    describe "searching for materials" do
      let(:get_params) { {} }
      before(:each) do
        get :search, params: get_params
      end

      describe "with no filter parameters" do
        it "should return search results that shows only external activity based materials" do
          expect(assigns[:search]).not_to be_nil
          expect(assigns[:search].results[Search::InvestigationMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::InvestigationMaterial].length).to be(1)
          assigns[:search].results[Search::InvestigationMaterial].each do |investigation|
            expect(all_investigations).to include(investigation)
          end
          expect(assigns[:search].results[Search::ActivityMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::ActivityMaterial].length).to be(4)
          assigns[:search].results[Search::ActivityMaterial].each do |activity|
            expect(all_activities).to include(activity)
          end
        end

        it "should return a count of the user's contributed activities" do
          expect(assigns[:search].number_authored_resources).to be(contributed_activities.count)
        end
      end

      describe "searching only official materials" do
        let(:get_params) { {:include_official => 1} }
        it "should show all official study materials" do
          expect(assigns[:search].results[Search::InvestigationMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::InvestigationMaterial].length).to be(1)
          assigns[:search].results[Search::InvestigationMaterial].each do |investigation|
            expect(all_investigations).to include(investigation)
          end
          expect(assigns[:search].results[Search::ActivityMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::ActivityMaterial].length).to be(3)  # 3 instead of 2 as we always show the user's own contributed activities
          assigns[:search].results[Search::ActivityMaterial].each do |activity|
            expect(official_activities).to include(activity)
          end
        end

        it "should not return any non-user contributed activities" do
          assigns[:search].results[Search::ActivityMaterial].each do |activity|
            expect(contributed_activities).not_to include(activity)
          end
        end

        it "should return user contributed activities" do
          assigns[:search].results[Search::ActivityMaterial].each do |activity|
            if !activity.is_official
              expect(user_contributed_activities).to include(activity)
            end
          end
        end
      end

      describe "searching only investigations" do
        let(:get_params) { {:material_types => [Search::InvestigationMaterial]} }
        let(:activity_results) {[]}

        it "should return all investigations" do
          expect(assigns[:search].results[Search::InvestigationMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::InvestigationMaterial].length).to be(1)
        end

        it "should not return any activities" do
          get :search, params: get_params
          expect(assigns[:search].results[Search::ActivityMaterial]).to be_nil
        end
      end

      describe "searching only activities" do
        let(:get_params) {{:material_types => [Search::ActivityMaterial]}}
        it "should not include investigations" do
          expect(assigns[:search].results[Search::InvestigationMaterial]).to be_nil
        end
        it "should return all activities" do
          expect(assigns[:search].results[Search::ActivityMaterial]).not_to be_nil
          expect(assigns[:search].results[Search::ActivityMaterial].length).to be(4)
          assigns[:search].results[Search::ActivityMaterial].each do |activity|
            expect(all_activities).to include(activity)
          end
        end
        describe "including contributed activities" do
          let(:get_params) {{ :material_types => ['Activity'], :include_contributed => 1 }}
          it "should include contributed activities" do
            expect(assigns[:search].results[Search::ActivityMaterial].length).to eq(2)
            expect(assigns[:search].results[Search::ActivityMaterial]).to include(contributed_activity)
          end
        end
      end

      describe "searching as a teacher who did not contribute any activities" do
        let(:get_params) { {} }
        it "should return a count of user contributed activities that equals zero" do
          sign_out :user
          sign_in teacher_user_2
          get :search, params: get_params
          expect(assigns[:search].number_authored_resources).to be(0)
        end
      end
    end
  end

  describe "GET search_suggestions" do
    it "should fail without a search_term parameter" do
      get :search_suggestions
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('{"success":false,"response_type":"ERROR","message":"Missing search_term parameter"}')
    end

    it "should succeed" do
      get :search_suggestions, params: { search_term: "test" }
      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result["success"]).to eq(true)
      expect(result["search_term"]).to eq("test")
      expect(result["suggestions"]).not_to eq(nil)
    end
  end
end
