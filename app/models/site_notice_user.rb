class SiteNoticeUser < ActiveRecord::Base
  belongs_to :site_notices, :class_name => "SiteNotice", :foreign_key => "notice_id"
  belongs_to :users, :class_name => "User", :foreign_key => "user_id"
  
  validates :notice_id, :user_id, :presence => true
end
