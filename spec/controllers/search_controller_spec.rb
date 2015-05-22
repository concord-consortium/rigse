require File.expand_path('../../spec_helper', __FILE__)

describe SearchController do
  include SolrSpecHelper

  def make(let); end

  let(:admin_settings)   { Factory.create(:admin_settings, :include_external_activities => false) }

  let(:mock_semester)   { Factory.create(:portal_semester, :name => "Fall") }
  let(:mock_school)     { Factory.create(:portal_school, :semesters => [mock_semester]) }

  let(:teacher_user)    { Factory.create(:confirmed_user, :login => "teacher_user") }
  let(:teacher)         { Factory.create(:portal_teacher, :user => teacher_user, :schools => [mock_school]) }
  let(:admin_user)      { Factory.next(:admin_user) }
  let(:author_user)     { Factory.next(:author_user) }
  let(:manager_user)    { Factory.next(:manager_user) }
  let(:researcher_user) { Factory.next(:researcher_user) }

  let(:student_user)    { Factory.create(:confirmed_user, :login => "authorized_student") }
  let(:student)         { Factory.create(:portal_student, :user_id => student_user.id) }

  let(:physics_investigation)     { Factory.create(:investigation, :name => 'physics_inv', :user => author_user, :publication_status => 'published') }
  let(:chemistry_investigation)   { Factory.create(:investigation, :name => 'chemistry_inv', :user => author_user, :publication_status => 'published') }
  let(:biology_investigation)     { Factory.create(:investigation, :name => 'mathematics_inv', :user => author_user, :publication_status => 'published') }
  let(:mathematics_investigation) { Factory.create(:investigation, :name => 'biology_inv', :user => author_user, :publication_status => 'published') }
  let(:lines)                     { Factory.create(:investigation, :name => 'lines_inv', :user => author_user, :publication_status => 'published') }

  let(:laws_of_motion_activity)  { Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => physics_investigation.id, :user => author_user) }
  let(:fluid_mechanics_activity) { Factory.create(:activity, :name => 'fluid_mechanics_activity' , :investigation_id => physics_investigation.id, :user => author_user) }
  let(:thermodynamics_activity)  { Factory.create(:activity, :name => 'thermodynamics_activity' , :investigation_id => physics_investigation.id, :user => author_user) }
  let(:parallel_lines)           { Factory.create(:activity, :name => 'parallel_lines' , :investigation_id => lines.id, :user => author_user) }

  let(:external_activity1)   { Factory.create(:external_activity, :name => 'external_1', :url => "http://concord.org", :publication_status => 'published', :is_official => true) }
  let(:external_activity2)   { Factory.create(:external_activity, :name => 'a_study_in_lines_and_curves', :url => "http://github.com", :publication_status => 'published', :is_official => true) }

  let(:contributed_activity) { Factory.create(:external_activity, :name => "Copy of external_1", :url => "http://concord.org", :publication_status => 'published', :is_official => false) }

  let(:all_investigations)    { [physics_investigation, chemistry_investigation, biology_investigation, mathematics_investigation, lines]}
  let(:official_activities)   { [laws_of_motion_activity, fluid_mechanics_activity, thermodynamics_activity, parallel_lines, external_activity1, external_activity2]}
  let(:contributed_activities){ [contributed_activity] }
  let(:all_activities)        {  official_activities.concat(contributed_activities) }
  let(:investigation_results) { [] }
  let(:activity_results)      { [] }

  let(:search_results) {{ Investigation => investigation_results, Activity => activity_results }}
  let(:mock_search)    { mock('results', {:results => search_results})}

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
      it "should redirect to root" do
        student # Ensure student_user has a PortalStudent
        controller.stub!(:current_visitor).and_return(student_user)
        get :index
        response.should redirect_to("/")
      end
    end

    describe "when there are no query parameters" do
      it "should redirect to ?include_official=1" do
        get :index
        response.should redirect_to action: :index, include_official: '1'
      end
    end
  end

  describe "Post get_current_material_unassigned_clazzes" do

    let(:physics_clazz)     { Factory.create(:portal_clazz, :name => 'Physics Clazz', :course => @mock_course,:teachers => [teacher]) }
    let(:chemistry_clazz)   { Factory.create(:portal_clazz, :name => 'Chemistry Clazz', :course => @mock_course,:teachers => [teacher]) }
    let(:mathematics_clazz) { Factory.create(:portal_clazz, :name => 'Mathematics Clazz', :course => @mock_course,:teachers => [teacher]) }

    let(:investigations_for_all_clazz) do
      inv = Factory.create(:investigation, :name => 'investigations_for_all_clazz', :user => author_user, :publication_status => 'published')
      #assign investigations_for_all_clazz to physics class
      Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(physics_clazz.id,'Investigation',inv.id)
      inv
    end

    let(:activity_for_all_clazz) do
      act = Factory.create(:activity, :name => 'activity_for_all_clazz' ,:investigation_id => physics_investigation.id, :user => author_user)
      #assign activity_for_all_clazz to physics class
      Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(physics_clazz.id,'Activity',act.id)
      act
    end

    before(:each) do
      #remove all the classes assigned to the teacher
      # FIXME: This is slow, and it seems like rspec must provide a more elegant way to set this up than to reset these every time.
      teacher.teacher_clazzes.each { |tc| tc.destroy }
      all_classes = [physics_clazz, chemistry_clazz, mathematics_clazz]
    end

    it "should get all the classes to which the activity is not assigned. Material to be assigned is a single activity" do
      post_params = {
        :material_type => 'Activity',
        :material_id => activity_for_all_clazz.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, post_params
      should render_template('_material_unassigned_clazzes')
      assigns[:material].should eq [activity_for_all_clazz]
      assigns[:assigned_clazzes].should eq [physics_clazz]
      assigns[:unassigned_clazzes].should eq [chemistry_clazz, mathematics_clazz]
    end

    it "should get all the classes to which the investigation is not assigned. Material to be assigned is a single investigation" do
      post_params = {
        :material_type => 'Investigation',
        :material_id => investigations_for_all_clazz.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, post_params
      assigns[:material].should eq [investigations_for_all_clazz]
      assigns[:assigned_clazzes].should eq [physics_clazz]
      assigns[:unassigned_clazzes].should eq [chemistry_clazz, mathematics_clazz]
    end

    it "should get all the classes to which the activity is not assigned. Material to be assigned is a multiple activity" do
      another_activity_for_all_clazz = Factory.create(:activity, :name => 'another_activity_for_all_clazz' ,:investigation_id => physics_investigation.id, :user => author_user)
      post_params = {
        :material_type => 'Activity',
        :material_id => "#{activity_for_all_clazz.id},#{another_activity_for_all_clazz.id}"
      }
      xhr :post, :get_current_material_unassigned_clazzes, post_params
      assigns[:material].should eq [activity_for_all_clazz, another_activity_for_all_clazz]
      assigns[:assigned_clazzes].should eq []
      assigns[:unassigned_clazzes].should eq [physics_clazz, chemistry_clazz, mathematics_clazz]
    end

  end
  describe "POST add_material_to_clazzes" do

    let(:clazz)         { Factory.create(:portal_clazz,:course => @mock_course,:teachers => [teacher]) }
    let(:another_clazz) { Factory.create(:portal_clazz,:course => @mock_course,:teachers => [teacher]) }

    let(:already_assigned_offering) { Factory.create(:portal_offering, :clazz_id=> clazz.id, :runnable_id=> chemistry_investigation.id, :runnable_type => 'Investigation'.classify) }
    let(:another_assigned_offering) { Factory.create(:portal_offering, :clazz_id=> clazz.id, :runnable_id=> laws_of_motion_activity.id, :runnable_type => 'Investigation'.classify) }

    it "should assign only unassigned investigations to the classes" do
      already_assigned_offering
      post_params = {
        :clazz_id => [clazz.id, another_clazz.id],
        :material_id => chemistry_investigation.id,
        :material_type => 'Investigation'
      }
      xhr :post, :add_material_to_clazzes, post_params

      runnable_id = post_params[:material_id]
      runnable_type = post_params[:material_type].classify

      offering_for_clazz = Portal::Offering.find_all_by_clazz_id_and_runnable_type_and_runnable_id(clazz.id, runnable_type, runnable_id)
      offering_for_another_clazz = Portal::Offering.find_all_by_clazz_id_and_runnable_type_and_runnable_id(another_clazz.id, runnable_type, runnable_id)

      offering_for_clazz.length.should be(1)
      offering_for_clazz.first.should == already_assigned_offering

      offering_for_another_clazz.length.should be(1)
      offering_for_another_clazz.first.runnable_id.should be(chemistry_investigation.id)
      offering_for_another_clazz.first.clazz_id.should be(another_clazz.id)
    end

    it "should assign activities to the classes" do
      another_assigned_offering
      post_params = {
        :clazz_id => [clazz.id, another_clazz.id],
        :material_id => "#{laws_of_motion_activity.id},#{fluid_mechanics_activity.id}",
        :material_type => 'Activity'
      }
      xhr :post, :add_material_to_clazzes, post_params

      runnable_ids = post_params[:material_id].split(',')
      runnable_type = post_params[:material_type].classify
      post_params[:clazz_id].each do |clazz_id|
        runnable_ids.each do |runnable_id|
          offering = Portal::Offering.find_all_by_clazz_id_and_runnable_type_and_runnable_id(clazz_id, runnable_type, runnable_id)
          offering.length.should be(1)
        end
      end
    end
  end

end
