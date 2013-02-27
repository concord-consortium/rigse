class BookmarkVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :bookmark

  scope :recent, limit(100).order("created_at DESC")

end
