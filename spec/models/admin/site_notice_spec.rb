require 'spec_helper'

describe Admin::SiteNotice do
  describe "Display notices for different users" do
    before(:each) do
      @admin_user = Factory.next(:admin_user)

      role = Role.find_by_title('admin')
      @first_notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      Factory.create(:site_notice_role, :notice_id => @first_notice.id,:role_id => role.id)

      @second_notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      Factory.create(:site_notice_role, :notice_id => @second_notice.id,:role_id => role.id)

      @third_notice = Factory.create(:site_notice, :created_by => @admin_user.id)
      Factory.create(:site_notice_role, :notice_id => @third_notice.id,:role_id => role.id)

    end
    it"should show no notice if there is no notice" do
      Admin::SiteNoticeRole.destroy_all
      Admin::SiteNotice.destroy_all
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      assert_equal(notices_hash[:notice_display_type] , Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:no_notice])
      assert_equal(notices_hash[:notices].length , 0)
    end
    it"should show uncollapsed notice container if there are recent notices" do
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      assert_equal(notices_hash[:notice_display_type] , Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:new_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      assert_equal(notice_ids.length, 3)
      assert(notice_ids.include?(@first_notice.id))
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
    it"should not show dismissed notices" do
      Factory.create(:site_notice_user, :notice_id => @first_notice.id,:user_id => @admin_user.id, :notice_dismissed => true)
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      assert_equal(notices_hash[:notice_display_type] , Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:new_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      assert_equal(notice_ids.length, 2)
      assert_equal(notice_ids.include?(@first_notice.id), false)
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
    it"should show collapsed notice container if there are no recent notices and user had collapsed the notice container" do
      Factory.create(:notice_user_display_status,:user_id => @admin_user.id,:last_collapsed_at_time => DateTime.now + 1.day, :collapsed_status => true)
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      assert_equal(notices_hash[:notice_display_type] , Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:collapsed_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      assert_equal(notice_ids.length, 3)
      assert(notice_ids.include?(@first_notice.id))
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
  end
end


