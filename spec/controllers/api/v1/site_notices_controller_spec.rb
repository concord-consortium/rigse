require 'spec_helper'

describe API::V1::SiteNoticesController do
  before(:each) do
    @mock_school = FactoryBot.create(:portal_school)

    @admin_user = FactoryBot.generate(:admin_user)
    @teacher_user = FactoryBot.create(:confirmed_user, :login => "teacher_user")
    @teacher_user.add_role('member')
    @teacher = FactoryBot.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])

    login_admin
  end

  describe "Dismiss a notice" do
    before(:each) do
      sign_in @teacher_user
      @notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      @params = {
        :id => @notice.id
      }
    end
    it"should dismiss a notice" do
      xhr :post, :dismiss_notice, @params
      dismissed_notice = Admin::SiteNoticeUser.find_by_notice_id_and_user_id(@notice.id, @teacher_user.id)
      expect(dismissed_notice).not_to be_nil
      assert(dismissed_notice.notice_dismissed)
      expect(response).to be_success
    end
  end
  describe "toggle_notice_display" do
    before(:each) do
      sign_in @teacher_user
      @notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
    end
    it"should store collapse time and expand and collapse status" do
      xhr :post, :toggle_notice_display
      toggle_notice_status = Admin::NoticeUserDisplayStatus.find_by_user_id(@teacher_user.id)
      expect(toggle_notice_status).not_to be_nil
      assert(toggle_notice_status.collapsed_status)
      expect(response).to be_success

      xhr :post, :toggle_notice_display
      toggle_notice_status.reload
      expect(toggle_notice_status).not_to be_nil
      expect(toggle_notice_status.collapsed_status).to eq(false)
      expect(response).to be_success
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
    it("should create a notice if and only if notice contains a non white space character") do
      post :update, @post_params
      notice = Admin::SiteNotice.find_by_notice_html(@post_params[:notice_html])
      expect(notice).not_to be_nil
    end
  end
end
