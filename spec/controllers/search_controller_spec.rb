require 'spec_helper'

describe SearchController do
  def setup_for_repeated_tests
    @controller = SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    @mock_semester = Factory.create(:portal_semester, :name => "Fall")
    @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
    @teacher_user = Factory.create(:user, :login => "teacher")
    @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
    @admin_user = Factory.next(:admin_user)
    @author_user = Factory.next(:author_user)
    @manager_user = Factory.next(:manager_user)
    @researcher_user = Factory.next(:researcher_user)
    @student_user = Factory.create(:user, :login => "authorized_student")
    
    @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user)
    @chemistry_investigation = Factory.create(:investigation, :name => 'chemistry_inv', :user => @author_user)
    @biology_investigation = Factory.create(:investigation, :name => 'mathematics_inv', :user => @author_user)
    @mathematics_investigation = Factory.create(:investigation, :name => 'biology_inv', :user => @author_user)

    @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
    @fluid_mechanics_activity = Factory.create(:activity, :name => 'fluid_mechanics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
    @thermodynamics_activity = Factory.create(:activity, :name => 'thermodynamics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
      
    stub_current_user :teacher_user
  end
  before(:each) do
    setup_for_repeated_tests
  end

  describe "Show all study materials materials" do
    it "should redirect to root for all the users other than teacher" do
      [@admin_user, @author_user, @manager_user, @researcher_user, @student_user].each do |user_other_than_teacher|
        controller.stub!(:current_user).and_return(user_other_than_teacher)
        @post_params = {
          :search_term => @laws_of_motion_activity.name,
          :activity => 'true',
          :investigation => nil
        }
        post :index
        response.should redirect_to("/")
      end
    end
    it "Show all study materials materials" do
      post :index
      assert_response :success
      assert_template 'index'
    end
  end

  describe "Search study materials" do
    it "should redirect to root for all the users other than teacher" do
      [@admin_user, @author_user, @manager_user, @researcher_user, @student_user].each do |user_other_than_teacher|
        controller.stub!(:current_user).and_return(user_other_than_teacher)
        @post_params = {
          :search_term => @laws_of_motion_activity.name,
          :activity => 'true',
          :investigation => nil
        }
        xhr :post, :show, @post_params
        response.should redirect_to("/")
        
        post :show, @post_params
        response.should redirect_to("/")
      end
    end
    it "should search activities" do
      @post_params = {
        :search_term => @laws_of_motion_activity.name,
        :activity => 'true',
        :investigation => nil
      }
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'offering_list'
      assert_select 'suggestions' , false
      
      post :show, @post_params
      assert_template "index"
    end

    it "should search investigations" do
      @post_params = {
        :search_term => @physics_investigation.name,
        :activity => nil,
        :investigation => 'true'
      }
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'offering_list'
      assert_select 'suggestions' , false
      
      post :show, @post_params
      assert_template "index"
    end
  end
  
  describe "get current material for the classes" do
    before(:each) do
      @clazz = Factory.create(:portal_clazz,:course => @mock_course,:teachers => [@teacher])
    end
    it "should get investigations that are unassigned to the class" do
      @post_params = {
        :material_type => 'Investigation',
        :material_id => @chemistry_investigation.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, @post_params
      assert_template :partial => '_material_unassigned_clazzes'
    end

    it "should get activities that are unassigned to the class" do
      @post_params = {
        :material_type => 'Activity',
        :material_id => @laws_of_motion_activity.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, @post_params
      assert_template :partial => '_material_unassigned_clazzes'
    end
  end
  
  describe "add materials to classes" do
    before(:each) do
      @clazz = Factory.create(:portal_clazz,:course => @mock_course,:teachers => [@teacher])
      @another_clazz = Factory.create(:portal_clazz,:course => @mock_course,:teachers => [@teacher])
    end
    it "should assign investigation to the classes" do
      @post_params = {
        :clazz_id => [@clazz.id, @another_clazz.id],
        :material_id => @chemistry_investigation.id,
        :material_type => 'Investigation'
      }
      xhr :post, :add_material_to_clazzes, @post_params
      
      runnable_id = @post_params[:material_id]
      runnable_type = @post_params[:material_type].classify
      offering_for_clazz = Portal::Offering.find_by_clazz_id_and_runnable_type_and_runnable_id(@clazz.id,runnable_type,runnable_id)
      offering_for_another_clazz = Portal::Offering.find_by_clazz_id_and_runnable_type_and_runnable_id(@another_clazz.id,runnable_type,runnable_id)
      
      assert_not_nil(offering_for_clazz)
      assert_not_nil(offering_for_another_clazz)
      assert_select_rjs :replace_html, "search_#{runnable_type.downcase}_#{runnable_id}"
    end
    it "should assign activity to the classes" do
      @post_params = {
        :clazz_id => [@clazz.id, @another_clazz.id],
        :material_id => @laws_of_motion_activity.id,
        :material_type => 'Activity'
      }
      xhr :post, :add_material_to_clazzes, @post_params
      
      runnable_id = @post_params[:material_id]
      runnable_type = @post_params[:material_type].classify
      offering_for_clazz = Portal::Offering.find_by_clazz_id_and_runnable_type_and_runnable_id(@clazz.id,runnable_type,runnable_id)
      offering_for_another_clazz = Portal::Offering.find_by_clazz_id_and_runnable_type_and_runnable_id(@another_clazz.id,runnable_type,runnable_id)
      
      assert_not_nil(offering_for_clazz)
      assert_not_nil(offering_for_another_clazz)
      assert_select_rjs :replace_html, "search_#{runnable_type.downcase}_#{runnable_id}"
    end
  end
end