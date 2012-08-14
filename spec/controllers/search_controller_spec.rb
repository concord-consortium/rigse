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
end