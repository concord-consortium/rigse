class Admin::NoticeUserDisplayStatus < ActiveRecord::Base

  attr_accessible :user_id, :last_collapsed_at_time, :collapsed_status

  self.table_name = "admin_notice_user_display_statuses"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  validates :user_id, :last_collapsed_at_time, :presence => true
end
