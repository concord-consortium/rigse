class Admin::NoticeUserDisplayStatus < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  validates :user_id, :last_collapsed_at_time, :presence => true
end
