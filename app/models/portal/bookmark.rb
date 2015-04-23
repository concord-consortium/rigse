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
  # Global filtering of scope, based on Admin Project settings. Note that {} block
  # is required so the expression is evaluated lazily and current settings are used.
  default_scope { where(:type => self.enabled_bookmark_types) }
  default_scope :order => 'position'
  acts_as_list

  def self.available_types
    [Portal::PadletBookmark, Portal::GenericBookmark]
  end

  def self.for_project
    self.where(:type => self.allowed_types)
  end

  def self.for_user(user)
    where(:user_id => user.id)
  end

  def self.enabled_bookmark_types
    # It may be overkill, but won't hurt and makes tests a bit easier
    # (no need to mock and stub default_settings).
    settings = Admin::Settings.default_settings
    return [] if !settings || !settings.enabled_bookmark_types
    return settings.enabled_bookmark_types
  end

  def self.allowed_types
    self.enabled_bookmark_types.map { |b| b.safe_constantize }
  end

  def self.is_allowed?
    return true if (self.allowed_types.include?(self))
    return false
  end

  def self.user_can_make?(user)
    return false if user.anonymous?
    return true if (self.is_allowed?)
  end

  def url=(url)
    unless url =~ /https?:\/\/(\S+)+\s*$/i
      url = "http://#{url.gsub(/^\/\/?/i, '')}"
    end
    write_attribute(:url, url)
  end

  def visits
    bookmark_visits
  end

  def record_visit(user)
    self.bookmark_visits << Portal::BookmarkVisit.new(:user => user)
  end
end
