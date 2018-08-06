require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SiteNoticesController do
  before(:each) do
    @mock_school = Factory.create(:portal_school)

    @admin_user = Factory.next(:admin_user)
    @teacher_user = Factory.create(:confirmed_user, :login => "teacher_user")
    @teacher_user.add_role('member')
    @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
    @manager_user = Factory.next(:manager_user)
    @researcher_user = Factory.next(:researcher_user)
    @author_user = Factory.next(:author_user)
    @student_user = Factory.create(:confirmed_user, :login => "authorized_student")
    @portal_student = Factory.create(:portal_student, :user => @student_user)
    @guest_user = Factory.next(:anonymous_user)

    @all_role_ids = Role.all.map {|r| r.id}

    login_admin
  end
  describe "GET new" do
    it"doesn't show notice create page to users with roles other than admin and manager" do
      get :new
      assert_template "new"

      sign_out :user
      sign_in @manager_user
      get :new
      assert_template "new"

      sign_out :user
      sign_in @teacher_user
      get :new
      response.should redirect_to("/recent_activity")

      sign_out :user
      sign_in @researcher_user
      get :new
      response.should redirect_to("/getting_started")

      sign_out :user
      sign_in @author_user
      get :new
      response.should redirect_to("/getting_started")

      sign_out :user
      sign_in @student_user
      get :new
      response.should redirect_to("/my_classes")

      sign_out :user
      sign_in @guest_user
      get :new
      response.should redirect_to("/getting_started")

    end
  end


  describe "Post new notice" do
    before(:each) do
      @post_params = {
        :notice_html =>"notice text should contain at least one non white space characters",
        :role => @all_role_ids
      }
    end

    it("should create a notice with some text and at least one role selected") do
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).not_to be_nil
      notice_id = notice.id
      notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(notice_id)
      expect(notice_roles).not_to be_nil
      notice_roles.each do |role|
        assert(@post_params[:role].include?(role.role_id))
      end
    end
    it("should not create a notice if it is blank") do
      @post_params[:notice_html] = ''
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      flash[:error].should =~ /Notice text is blank/i

      @post_params[:notice_html] = ' '
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      flash[:error].should =~ /Notice text is blank/i
    end
    it("should not create a notice if no role is selected") do
      @post_params[:role] = nil
      post :create, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
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
    it("should create a notice if and only if notice contains a non white space character and at least one role is selected") do
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).not_to be_nil
      notice_id = notice.id
      notice_roles = Admin::SiteNoticeUser.find_all_by_notice_id(notice_id)
      expect(notice_roles).not_to be_nil
      notice_roles.each do |role|
        assert(@post_params[:role].include?(role.role_id))
      end
    end
    it("should not create a notice if notice text is blank") do
      @post_params[:notice_html] = ""
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      flash[:error].should =~ /Notice text is blank/i

      @post_params[:notice_html] = "       "
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      flash[:error].should =~ /Notice text is blank/i
    end
    it("should not create a notice if no role is selected") do
      @post_params[:role] = nil
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
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
      expect(notice).not_to be_nil

      xhr :post, :remove_notice, @params
      notice = Admin::SiteNotice.find_by_id(@params[:id])
      expect(notice).to be_nil
      notice_roles = Admin::SiteNoticeRole.find_by_notice_id(@params[:id])
      expect(notice_roles).to be_nil
      response.should be_success
    end
  end
  describe "Dismiss a notice" do
    before(:each) do
      sign_in @teacher_user
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
      expect(dismissed_notice).not_to be_nil
      assert(dismissed_notice.notice_dismissed)
      response.should be_success
    end
  end
  describe "toggle_notice_display" do
    before(:each) do
      sign_in @teacher_user
      @notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      roles = Role.all
      roles.each do |role|
        Factory.create(:site_notice_role, :notice_id => @notice.id,:role_id => role.id)
      end
    end
    it"should store collapse time and expand and collapse status" do
      xhr :post, :toggle_notice_display
      toggle_notice_status = Admin::NoticeUserDisplayStatus.find_by_user_id(@teacher_user.id)
      expect(toggle_notice_status).not_to be_nil
      assert(toggle_notice_status.collapsed_status)
      response.should be_success

      xhr :post, :toggle_notice_display
      toggle_notice_status.reload
      expect(toggle_notice_status).not_to be_nil
      expect(toggle_notice_status.collapsed_status).to eq(false)
      response.should be_success
    end
  end
end
