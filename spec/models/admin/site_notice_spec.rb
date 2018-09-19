require 'spec_helper'

describe Admin::SiteNotice do
  describe "Display notices for different users" do
    before(:each) do
      @admin_user = FactoryBot.generate(:admin_user)

      role = Role.find_by_title('admin')
      @first_notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      FactoryBot.create(:site_notice_role, :notice_id => @first_notice.id,:role_id => role.id)

      @second_notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      FactoryBot.create(:site_notice_role, :notice_id => @second_notice.id,:role_id => role.id)

      @third_notice = FactoryBot.create(:site_notice, :created_by => @admin_user.id)
      FactoryBot.create(:site_notice_role, :notice_id => @third_notice.id,:role_id => role.id)

    end
    it"should show no notice if there is no notice" do
      Admin::SiteNoticeRole.destroy_all
      Admin::SiteNotice.destroy_all
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      expect(notices_hash[:notice_display_type] ).to eq(Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:no_notice])
      expect(notices_hash[:notices].length ).to eq(0)
    end
    it"should show uncollapsed notice container if there are recent notices" do
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      expect(notices_hash[:notice_display_type] ).to eq(Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:new_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      expect(notice_ids.length).to eq(3)
      assert(notice_ids.include?(@first_notice.id))
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
    it"should not show dismissed notices" do
      FactoryBot.create(:site_notice_user, :notice_id => @first_notice.id,:user_id => @admin_user.id, :notice_dismissed => true)
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      expect(notices_hash[:notice_display_type] ).to eq(Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:new_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      expect(notice_ids.length).to eq(2)
      expect(notice_ids.include?(@first_notice.id)).to eq(false)
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
    it"should show collapsed notice container if there are no recent notices and user had collapsed the notice container" do
      FactoryBot.create(:notice_user_display_status,:user_id => @admin_user.id,:last_collapsed_at_time => DateTime.now + 1.day, :collapsed_status => true)
      notices_hash = Admin::SiteNotice.get_notices_for_user(@admin_user)
      expect(notices_hash[:notice_display_type] ).to eq(Admin::SiteNotice.NOTICE_DISPLAY_TYPES[:collapsed_notices])

      notice_ids = notices_hash[:notices].map {|n| n.id}
      expect(notice_ids.length).to eq(3)
      assert(notice_ids.include?(@first_notice.id))
      assert(notice_ids.include?(@second_notice.id))
      assert(notice_ids.include?(@third_notice.id))
    end
  end


  # TODO: auto-generated
  describe '.NOTICE_DISPLAY_TYPES' do
    it 'NOTICE_DISPLAY_TYPES' do
      result = described_class.NOTICE_DISPLAY_TYPES

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.get_notices_for_user' do
    it 'get_notices_for_user' do
      user = FactoryBot.create(:user)
      result = described_class.get_notices_for_user(user)

      expect(result).not_to be_nil
    end
  end


end
