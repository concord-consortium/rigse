class Admin::SiteNoticeUser < ActiveRecord::Base
  self.table_name = "admin_site_notice_users"
  belongs_to :admin_site_notice, :class_name => 'Admin::SiteNotice', :foreign_key => 'notice_id', :primary_key => 'id'
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  validates :notice_id, :user_id, :presence => true
end
