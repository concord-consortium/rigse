class Admin::SiteNoticeRole < ActiveRecord::Base
  belongs_to :site_notice, :class_name => "SiteNotice", :foreign_key => "notice_id"
  belongs_to :role, :class_name => "Role", :foreign_key => "role_id"
  
  validates :notice_id, :role_id, :presence => true
end
