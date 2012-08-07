require 'spec_helper'

describe SearchController do
  def setup_for_repeated_tests
    @controller = SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    @mock_semester = Factory.create(:portal_semester, :name => "Fall")
    @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
    @author_user = Factory.next(:author_user)
    @teacher_user = Factory.create(:user, :login => "teacher")
    @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
  end
  before(:each) do
    setup_for_repeated_tests
  end
  describe "Search study materials" do
    before(:each) do
      @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user)
      @chemistry_investigation = Factory.create(:investigation, :name => 'chemistry_inv', :user => @author_user)
      @biology_investigation = Factory.create(:investigation, :name => 'mathematics_inv', :user => @author_user)
      @mathematics_investigation = Factory.create(:investigation, :name => 'biology_inv', :user => @author_user)

      @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
      @fluid_mechanics_activity = Factory.create(:activity, :name => 'fluid_mechanics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
      @thermodynamics_activity = Factory.create(:activity, :name => 'thermodynamics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
      
      stub_current_user :teacher_user
    end
    it "should search activities" do
      @post_params = {
        :search_term => @laws_of_motion_activity.name,
        :activity => 'true',
        :investigation => nil,
        :show_suggestion => 'true'
      }
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'search_suggestions'
      assert_select_rjs :replace_html, 'offering_list'
      
      @post_params[:show_suggestion] = 'false'
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'offering_list'
      
      post :show, @post_params
      assert_template "index"
    end

    it "should search investigations" do
      @post_params = {
        :search_term => @physics_investigation.name,
        :activity => nil,
        :investigation => 'true',
        :show_suggestion => 'true'
      }
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'search_suggestions'
      assert_select_rjs :replace_html, 'offering_list'
      
      @post_params[:show_suggestion] = 'false'
      
      xhr :post, :show, @post_params
      assert_select_rjs :replace_html, 'offering_list'
      
      post :show, @post_params
      assert_template "index"
    end
  end
end