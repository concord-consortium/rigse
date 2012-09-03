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
    
    @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user, :publication_status => 'published')
    @chemistry_investigation = Factory.create(:investigation, :name => 'chemistry_inv', :user => @author_user, :publication_status => 'published')
    @biology_investigation = Factory.create(:investigation, :name => 'mathematics_inv', :user => @author_user, :publication_status => 'published')
    @mathematics_investigation = Factory.create(:investigation, :name => 'biology_inv', :user => @author_user, :publication_status => 'published')
    @lines = Factory.create(:investigation, :name => 'lines_inv', :user => @author_user, :publication_status => 'published')

    @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
    @fluid_mechanics_activity = Factory.create(:activity, :name => 'fluid_mechanics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
    @thermodynamics_activity = Factory.create(:activity, :name => 'thermodynamics_activity' , :investigation_id => @physics_investigation.id, :user => @author_user)
    @parallel_lines = Factory.create(:activity, :name => 'parallel_lines' , :investigation_id => @lines.id, :user => @author_user)
      
    stub_current_user :teacher_user
  end
  before(:each) do
    setup_for_repeated_tests
  end

  describe "GET index" do
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
    it "should show all study materials materials" do
      post :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns[:investigations]
      assert_not_nil assigns[:investigations_count]
      assert_equal assigns[:investigations_count], 5
      all_investigations = [@physics_investigation, @chemistry_investigation, @biology_investigation, @mathematics_investigation, @lines]
      retrieved_investigations = assigns[:investigations]
      retrieved_investigations.each do |investigation|
        assert(all_investigations.include?(investigation))
      end
      assert_not_nil assigns[:activities]
      assert_not_nil assigns[:activities_count]
      assert_equal assigns[:activities_count], 4
      all_activities = [@laws_of_motion_activity, @fluid_mechanics_activity, @thermodynamics_activity, @parallel_lines]
      retrieved_activities = assigns[:activities]
      retrieved_activities.each do |activity|
        assert(all_activities.include?(activity))
      end
    end
    it "should search investigations" do
      @post_params = {
        :material => ['investigation']
      }
      post :index,@post_params
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns[:investigations]
      assert_not_nil assigns[:investigations_count]
      assert_equal assigns[:investigations_count], 5
      all_investigations = [@physics_investigation, @chemistry_investigation, @biology_investigation, @mathematics_investigation, @lines]
      retrieved_investigations = assigns[:investigations]
      retrieved_investigations.each do |investigation|
        assert(all_investigations.include?(investigation))
      end
      assert_nil assigns[:activities]
      assert_equal assigns[:activities_count],0
    end
    it "should search activities" do
      @post_params = {
        :material => ['activity']
      }
      post :index,@post_params
      assert_response :success
      assert_template 'index'
      assert_nil assigns[:investigations]
      assert_equal assigns[:investigations_count], 0
      assert_not_nil assigns[:activities]
      assert_not_nil assigns[:activities_count]
      assert_equal assigns[:activities_count], 4
      all_activities = [@laws_of_motion_activity, @fluid_mechanics_activity, @thermodynamics_activity, @parallel_lines]
      retrieved_activities = assigns[:activities]
      retrieved_activities.each do |activity|
        assert(all_activities.include?(activity))
      end
    end
  end

  describe "POST show" do
    it "should redirect to root for all the users other than teacher" do
      [@admin_user, @author_user, @manager_user, @researcher_user, @student_user].each do |user_other_than_teacher|
        controller.stub!(:current_user).and_return(user_other_than_teacher)
        @post_params = {
          :search_term => @laws_of_motion_activity.name,
          :activity => 'true',
          :investigation => nil
        }
        xhr :post, :show, @post_params
        response.should redirect_to(:root)
        
        post :show, @post_params
        response.should redirect_to(:root)
      end
    end
    it "should search all study materials materials matching the search term" do
      @post_params = {
        :search_term => 'lines',
        :material => ['activity', 'investigation']
      }
      xhr :post, :show, @post_params
      assert_equal assigns[:investigations_count], 1
      assigns[:investigations] = [@lines]
      assert_equal assigns[:activities_count], 1
      assigns[:activities] = [@parallel_lines]
      assert_select_rjs :replace_html, 'offering_list'
      assert_select 'suggestions' , false
    end
    it "should search activities matching the search term" do
      @post_params = {
        :search_term => @laws_of_motion_activity.name,
        :material => ['activity']
      }
      
      xhr :post, :show, @post_params
      assert_not_nil assigns(:activities_count)
      assert_equal assigns(:activities_count), 1
      assigns[:activities] = [@laws_of_motion_activity]
      assert_equal assigns(:investigations_count), 0
      assert_select_rjs :replace_html, 'offering_list'
      assert_select 'suggestions' , false
      
      post :show, @post_params
      assert_template "index"
    end

    it "should search investigations matching the search term" do
      @post_params = {
        :search_term => @physics_investigation.name,
        :activity => nil,
        :investigation => 'true'
      }
      
      xhr :post, :show, @post_params
      assert_not_nil assigns(:investigations_count)
      assert_equal assigns(:investigations_count), 1
      assigns[:investigations] = [@physics_investigation]
      assert_equal assigns(:activities_count), 0
      assert_select_rjs :replace_html, 'offering_list'
      assert_select 'suggestions' , false
      
      post :show, @post_params
      assert_template "index"
    end
  end
  
  describe "Post get_current_material_unassigned_clazzes" do
    before(:each) do
      #remove all the classes assigned to the teacher
      teacher_clazzes = Portal::TeacherClazz.where(:teacher_id => @teacher.id)
      teacher_clazzes.each do |teacher_clazz|
        teacher_clazz.destroy
      end
      #assign new classes to the teacher
      @physics_clazz = Factory.create(:portal_clazz, :name => 'Physics Clazz', :course => @mock_course,:teachers => [@teacher])
      @chemistry_clazz = Factory.create(:portal_clazz, :name => 'Chemistry Clazz', :course => @mock_course,:teachers => [@teacher])
      @mathematics_clazz = Factory.create(:portal_clazz, :name => 'Mathematics Clazz', :course => @mock_course,:teachers => [@teacher])
      
      @investigations_for_all_clazz = Factory.create(:investigation, :name => 'investigations_for_all_clazz', :user => @author_user, :publication_status => 'published')
      @activity_for_all_clazz = Factory.create(:activity, :name => 'activity_for_all_clazz' ,:investigation_id => @physics_investigation.id, :user => @author_user)
    
      #assign activity_for_all_clazz to physics class
      Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@physics_clazz.id,'Activity',@activity_for_all_clazz.id)
      
      #assign investigations_for_all_clazz to physics class
      Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(@physics_clazz.id,'Investigation',@investigations_for_all_clazz.id)
    end
    it "should get all the classes to which the activity is not assigned" do
      @post_params = {
        :material_type => 'Activity',
        :material_id => @activity_for_all_clazz.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, @post_params
      assert_template :partial => '_material_unassigned_clazzes'
      assigns[:material].should eq @activity_for_all_clazz
      assigns[:assigned_clazzes].should eq [@physics_clazz]
      assigns[:unassigned_clazzes].should eq [@chemistry_clazz, @mathematics_clazz]
    end
    it "should get all the classes to which the investigation is not assigned" do
      @post_params = {
        :material_type => 'Investigation',
        :material_id => @investigations_for_all_clazz.id
      }
      xhr :post, :get_current_material_unassigned_clazzes, @post_params
      assert_template :partial => '_material_unassigned_clazzes'
      assigns[:material].should eq @investigations_for_all_clazz
      assigns[:assigned_clazzes].should eq [@physics_clazz]
      assigns[:unassigned_clazzes].should eq [@chemistry_clazz, @mathematics_clazz]
    end
  end  
  describe "POST add_material_to_clazzes" do
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