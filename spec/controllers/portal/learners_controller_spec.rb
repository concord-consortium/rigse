require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::LearnersController do
  it "should render the config builder" do
  	@controller.stub!(:current_project).and_return(
  		mock(:project, 
  			:use_periodic_bundle_uploading? => false,
  			:use_student_security_questions => false,
  			:require_user_consent? => false)
  	)
  	learner = Factory(:full_portal_learner)
  	stub_current_user(learner.student.user)
  	get :show, :format => :config, :id => learner.id
  end


  it "should raise an exception when unauthorized config request is made" do
  	@controller.stub!(:current_project).and_return(
  		mock(:project, 
  			:use_periodic_bundle_uploading? => false,
  			:use_student_security_questions => false,
  			:require_user_consent? => false)
  	)
  	learner = Factory(:full_portal_learner)
  	lambda { 
  		get :show, :format => :config, :id => learner.id
  	}.should raise_error
  	
  end
  
  describe "GET activity_report" do 
    before(:each) do
      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
      @teacher_user = Factory.create(:user, :login => "teacher")
      @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
      @author_user = Factory.next(:author_user)
      @student_user = Factory.create(:user)
      @student = Factory.create(:portal_student,:user_id=> @student_user.id)
      @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user, :publication_status => 'published')
      @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
      @physics_clazz = Factory.create(:portal_clazz, :name => 'Physics Clazz', :course => @mock_course,:teachers => [@teacher])
      @offering=Factory.create(:portal_offering,:status=>'active',:runnable_id=>@laws_of_motion_activity.id,:runnable_type=>'Activity',:clazz=>@physics_clazz)
      @portal_learner=Factory.create(:portal_learner,:offering_id=>@offering.id, :student_id => @student.id)
      @portal_student_clazz=Factory.create(:portal_student_clazz,:student_id=>@student.id,:clazz_id=>@physics_clazz.id)
      @section=Factory.create(:section,:user_id=>@teacher_user.id,:activity_id=>@laws_of_motion_activity.id)
      @page=Factory.create(:page,:user_id=>@teacher_user.id,:section_id=>@section.id)
      @embeddable=Factory.create(:embeddable_xhtml,:user_id=>@teacher_user.id)
      @page.add_embeddable(@embeddable)
      stub_current_user :teacher_user
    end
    it "should open report of a particular activity for corresponding learner" do
      @post_params = {
        :id => @portal_learner.id,
        :activity_id => @laws_of_motion_activity.id
      }
      get :activity_report, @post_params
      
      
      assert_not_nil assigns[:offering]
      assert_equal assigns[:offering].clazz, @physics_clazz
      
      assert_not_nil session[:activity_report_embeddable_filter]
      assert_equal session[:activity_report_embeddable_filter].count, 1
      assert_equal session[:activity_report_embeddable_filter][0], @embeddable
      
      assert_response :redirect
      response.should redirect_to(report_portal_learner_url(@portal_learner))
    end
    
    it "should open report of all activities for corresponding learner" do
      @post_params = {
        :id => @portal_learner.id
      }
      get :activity_report, @post_params
      
      assert_not_nil assigns[:offering]
      assert_equal assigns[:offering].clazz, @physics_clazz
      
      assert_nil session[:activity_report_embeddable_filter]
      
      assert_response :redirect
      response.should redirect_to(report_portal_learner_url(@portal_learner))
    end
  end
  
end
