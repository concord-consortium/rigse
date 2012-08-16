require 'spec_helper'

describe Admin::SiteNoticesController do
  def setup_for_repeated_tests
    @controller = Admin::SiteNoticesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    @mock_semester = Factory.create(:portal_semester, :name => "Fall")
    @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])

    @admin_user = Factory.next(:admin_user)
    @teacher_user = Factory.create(:user, :login => "teacher")
    @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
    @manager_user = Factory.next(:manager_user)
    @researcher_user = Factory.next(:researcher_user)
    @author_user = Factory.next(:author_user)
    @student_user = Factory.create(:user, :login => "authorized_student")
    @portal_student = Factory.create(:portal_student, :user => @student_user)
    @guest_user = Factory.next(:anonymous_user)

    @all_role_ids = Role.all.map {|r| r.id}

  end
  before(:each) do
    setup_for_repeated_tests
    stub_current_user :admin_user
  end
  describe "GET new" do
    it"doesn't show notice create page to users with roles other than admin and manager" do

      get :new
      assert_template "new"

      stub_current_user :manager_user
      get :new
      assert_template "new"

      error_msg = /Please log in as an administrator or manager/i

      stub_current_user :teacher_user
      get :new
      response.should redirect_to("/home")
      flash[:error].should =~ error_msg

      stub_current_user :researcher_user
      get :new
      response.should redirect_to("/home")
      flash[:error].should =~ error_msg

      stub_current_user :author_user
      get :new
      response.should redirect_to("/home")
      flash[:error].should =~ error_msg

      stub_current_user :student_user
      get :new
      response.should redirect_to("/home")
      flash[:error].should =~ error_msg

      stub_current_user :guest_user
      get :new
      response.should redirect_to("/home")
      flash[:error].should =~ error_msg

    end
  end


  describe "Post new notice" do
    before(:each) do
      @post_params = {
        :notice_html =>"notice text should contain atleast one non white space characters",
        :role => @all_role_ids
      }
    end

    it("should create a notice with some text and atleast one role selected") do
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_not_nil(notice)
      notice_id = notice.id
      notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(notice_id)
      assert_not_nil(notice_roles)
      notice_roles.each do |role|
        assert(@post_params[:role].include?(role.role_id))
      end
    end
    it("should not create a notice if it is blank") do
      @post_params[:notice_html] = ''
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /Notice text is blank/i

      @post_params[:notice_html] = ' '
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /Notice text is blank/i
    end
    it("should not create a notice if no role is selected") do
      @post_params[:role] = nil
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /No role is selected/i
    end
  end


  describe "GET edit notice form" do
    before(:each) do
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
      @params = {
        :id => @notice.id
      }
    end
    it"should show edit notice form" do
      get :edit, @params
      assert_template "edit"
    end
  end

  describe "Update a notice after saving it" do
    before(:each) do
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
      @post_params = {
        :notice_html =>"updated text",
        :role => @all_role_ids,
        :id => @notice.id
      }
    end
    it("should create a notice if and only if notice contains a non white space character and atleast one role is selected") do
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_not_nil(notice)
      notice_id = notice.id
      notice_roles = Admin::SiteNoticeUser.find_all_by_notice_id(notice_id)
      assert_not_nil(notice_roles)
      notice_roles.each do |role|
        assert(@post_params[:role].include?(role.role_id))
      end
    end
    it("should not create a notice if notice text is blank") do
      @post_params[:notice_html] = ""
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /Notice text is blank/i

      @post_params[:notice_html] = "       "
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /Notice text is blank/i
    end
    it("should not create a notice if no role is selected") do
      @post_params[:role] = nil
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      assert_nil(notice)
      flash[:error].should =~ /No role is selected/i
    end
  end

  describe "Delete a Notice" do
    before(:each) do
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
      @params= {
        :id => @notice.id
      }
    end
    it"should delete a notice" do

      # Check the notice exists before checking that it is deleted
      notice = Admin::SiteNotice.find_by_id(@params[:id])
      assert_not_nil(notice)
      
      xhr :post, :remove_notice, @params
      notice = Admin::SiteNotice.find_by_id(@params[:id])
      assert_nil(notice)
      notice_roles = Admin::SiteNoticeRole.find_by_notice_id(@params[:id])
      assert_nil(notice_roles)
      response.should be_success
    end
  end
  describe "Dismiss a notice" do
    before(:each) do
      stub_current_user :teacher_user
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
      @params = {
        :id => @notice.id
      }
    end
    it"should dismiss a notice" do
      xhr :post, :dismiss_notice, @params
      dismissed_notice = Admin::SiteNoticeUser.find_by_notice_id_and_user_id(@notice.id, @teacher_user.id)
      assert_not_nil(dismissed_notice)
      assert(dismissed_notice.notice_dismissed)
      response.should be_success
    end
  end
  describe "toggle_notice_display" do
    before(:each) do
      stub_current_user :teacher_user
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
    end
    it"should store collapse time and expand and collapse status" do
      xhr :post, :toggle_notice_display
      toggle_notice_status = Admin::NoticeUserDisplayStatus.find_by_user_id(@teacher_user.id)
      assert_not_nil(toggle_notice_status)
      assert(toggle_notice_status.collapsed_status)
      response.should be_success

      xhr :post, :toggle_notice_display
      toggle_notice_status.reload
      assert_not_nil(toggle_notice_status)
      assert_equal(toggle_notice_status.collapsed_status, false)
      response.should be_success
    end
  end
end
