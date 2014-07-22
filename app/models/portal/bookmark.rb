class Portal::Bookmark < ActiveRecord::Base
  include Changeable
  self.table_name = :portal_bookmarks

  # TODO: Its probably best not to use this type directly.
  attr_accessible :name, :url, :user_id, :user
  belongs_to :user
  belongs_to :clazz, :class_name => "Portal::Clazz"
  has_many   :bookmark_visits, :dependent => :destroy
  validates_presence_of :user
  validates_presence_of :url
  default_scope :order => 'position'
  acts_as_list

  url_regex      = /https?:\/\/(\S+)+\s*$/i
  validates_format_of :url,  :with => url_regex

  def self.available_types
    [Portal::PadletBookmark, Portal::GenericBookmark]
  end

  def self.for_project
    self.where(:type => self.allowed_types)
  end

  def self.for_user(user)
    where(:user_id => user.id)
  end

  # Useful for SLQ queries.
  def self.allowed_types_raw
    Admin::Project.default_project.enabled_bookmark_types
  end

  def self.allowed_types
    Admin::Project.default_project.enabled_bookmark_types.map {|b| b.safe_constantize}
  end

  def self.is_allowed?
    return true if (self.allowed_types.include?(self))
    return false
  end

  def self.user_can_make?(user)
    return false if user.anonymous?
    return true if (self.is_allowed?)
  end

  def visits
    bookmark_visits
  end

  def record_visit(user)
    self.bookmark_visits << Portal::BookmarkVisit.new(:user => user)
  end
end
