class Admin::SiteNoticeRole < ActiveRecord::Base
  self.table_name = "admin_site_notice_roles"
  belongs_to :admin_site_notice, :class_name => 'Admin::SiteNotice', :foreign_key => 'notice_id', :primary_key => 'id'
  belongs_to :role, :class_name => "Role", :foreign_key => "role_id"
  
  validates :notice_id, :role_id, :presence => true
end
