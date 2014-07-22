class Portal::BookmarkVisit < ActiveRecord::Base
  self.table_name = :portal_bookmark_visits

  belongs_to :user
  belongs_to :bookmark

  scope :recent, limit(100).order("created_at DESC")
end
