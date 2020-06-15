require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SiteNoticesController do
  before(:each) do
    @mock_school = FactoryBot.create(:portal_school)

    @admin_user = FactoryBot.generate(:admin_user)
    @teacher_user = FactoryBot.create(:confirmed_user, :login => "teacher_user")
    @teacher_user.add_role('member')
    @teacher = FactoryBot.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
    @manager_user = FactoryBot.generate(:manager_user)
    @researcher_user = FactoryBot.generate(:researcher_user)
    @author_user = FactoryBot.generate(:author_user)
    @student_user = FactoryBot.create(:confirmed_user, :login => "authorized_student")
    @portal_student = FactoryBot.create(:portal_student, :user => @student_user)
    @guest_user = FactoryBot.generate(:anonymous_user)

    login_admin
  end
  describe "GET new" do
    it"doesn't show notice create page to users with roles other than admin and manager" do
      get :new
      expect(response).to render_template("new")

      sign_out :user
      sign_in @manager_user
      get :new
      expect(response).to render_template("new")

      sign_out :user
      sign_in @teacher_user
      get :new
      expect(response).to redirect_to("/recent_activity")

      sign_out :user
      sign_in @researcher_user
      get :new
      expect(response).to redirect_to("/getting_started")

      sign_out :user
      sign_in @author_user
      get :new
      expect(response).to redirect_to("/getting_started")

      sign_out :user
      sign_in @student_user
      get :new
      expect(response).to redirect_to("/my_classes")

      sign_out :user
      sign_in @guest_user
      get :new
      expect(response).to redirect_to("/getting_started")

    end
  end

  describe "GET edit notice form" do
    before(:each) do
      @notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      @params = {
        :id => @notice.id
      }
    end
    it"should show edit notice form" do
      get :edit, @params
      expect(response).to render_template("edit")
    end
  end

  describe "Update a notice after saving it" do
    before(:each) do
      @notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      @post_params = {
        :notice_html =>"updated text",
        :id => @notice.id
      }
    end
    it("should not create a notice if notice text is blank") do
      @post_params[:notice_html] = ""
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      expect(flash[:error]).to match(/Notice text is blank/i)

      @post_params[:notice_html] = "       "
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).to be_nil
      expect(flash[:error]).to match(/Notice text is blank/i)
    end
  end

end
