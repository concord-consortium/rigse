class Admin::SiteNotice < ActiveRecord::Base
  self.table_name = "admin_site_notices"
  has_many :admin_site_notice_roles, :class_name => 'Admin::SiteNoticeRole', :foreign_key => 'notice_id', :primary_key => 'id'
  has_many :admin_site_notice_users, :class_name => 'Admin::SiteNoticeUser', :foreign_key => 'notice_id', :primary_key => 'id'
  
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  
  validates :notice_html, :created_by, :presence => true
  
  
  @@NOTICE_DISPLAY_TYPES = {
    :no_notice => 1,
    :new_notices => 2,
    :collapsed_notices => 3
  }
  
  def self.NOTICE_DISPLAY_TYPES
    return @@NOTICE_DISPLAY_TYPES
  end
  
  def self.get_notices_for_user(user)
    notices_hash = {
      :notices => [],
      :notice_display_type => self.NOTICE_DISPLAY_TYPES[:no_notice]
    }
    
    # Notices should not be displayed for students
    if user.portal_student
      return notices_hash
    end
    all_notices = Array.new
    user_roles = user.roles
    user_roles.each do |role|
      notice_roles = role.admin_site_notice_roles
      if(notice_roles)
        notice_roles.each do |notice_role|
          notice_dismissed = Admin::SiteNoticeUser.find_by_notice_id_and_user_id(notice_role.admin_site_notice.id, user.id)
          all_notices << notice_role.admin_site_notice if notice_dismissed.nil? or (notice_role.admin_site_notice.updated_at > notice_dismissed.updated_at)
        end
      end
    end
    all_notices = all_notices.uniq
    all_notices = all_notices.sort{|a,b| b.updated_at <=> a.updated_at }
    if(all_notices.length == 0)
      return notices_hash
    end
    
    notices_hash[:notices] = all_notices
    notices_hash[:notice_display_type] = self.NOTICE_DISPLAY_TYPES[:new_notices]
    latest_notice_time = all_notices.first.updated_at
    notice_user_display_status = Admin::NoticeUserDisplayStatus.find_by_user_id(user.id)
    if notice_user_display_status && notice_user_display_status.collapsed_status
      if latest_notice_time < Admin::NoticeUserDisplayStatus.find_by_user_id(user.id).last_collapsed_at_time
        notices_hash[:notice_display_type] = self.NOTICE_DISPLAY_TYPES[:collapsed_notices]
      end
    end
    
    return notices_hash
  end
end
