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
  
  describe "GET report" do 
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
    
    it "should show learner report when no filter is set" do
      @post_params = {
        :id => @portal_learner.id,
      }
      get :report, @post_params
      assert_template 'report'
      assert_equal assigns[:portal_learner], @portal_learner
    end
    
    it "should show learner report when filter is set" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @portal_learner.id
      }
      get :report, @post_params
      assert_template 'report'
      assert_equal assigns[:portal_learner], @portal_learner
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      
    end
    
    it "should show learner report for an activity when filter is set and ignore is set to false for report embeddable filter" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.ignore = false
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @portal_learner.id,
        :activity_id => @laws_of_motion_activity.id
      }
      get :report, @post_params
      assert_template 'report'
      assert_equal assigns[:portal_learner], @portal_learner
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      assert_equal assigns[:activity_report_id], @post_params[:activity_id].to_i
      @portal_learner.reload
      @offering.reload
      assert_equal assigns[:portal_learner].offering.report_embeddable_filter.embeddables, [@embeddable]
      assert_equal assigns[:portal_learner].offering.report_embeddable_filter.ignore, false
    end
    
    it "should show learner report for an activity when filter is set and ignore is set to true for report embeddable filter" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.ignore = true
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @portal_learner.id,
        :activity_id => @laws_of_motion_activity.id
      }
      get :report, @post_params
      assert_template 'report'
      assert_equal assigns[:portal_learner], @portal_learner
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      assert_equal assigns[:activity_report_id], @post_params[:activity_id].to_i
      @portal_learner.reload
      @offering.reload
      assert_equal assigns[:portal_learner].offering.report_embeddable_filter.embeddables, [@embeddable]
      assert_equal assigns[:portal_learner].offering.report_embeddable_filter.ignore, false
    end
  end
  
end
