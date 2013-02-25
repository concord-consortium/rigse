class Bookmark < ActiveRecord::Base
  # include Changeable
  # TODO: Its probably best not to use this type directly.
  attr_accessible :name, :url, :user_id, :user
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :url


  def self.available_types
    [PadletBookmark, GenericBookmark]
  end

  def self.for_project
    self.where(:type => self.allowed_types)
  end

  def self.for_user(user)
    where(:user_id => user.id)
  end

  def self.allowed_types
    Admin::Project.default_project.enabled_bookmark_types.map {|b| b.safe_constantize}
  end

  def self.is_allowed?
    return true if (self.allowed_types.include?(self))
    return false
  end

  def self.user_can_make?(user)
    return true if (self.is_allowed?)
  end

end
