class Bookmark < ActiveRecord::Base
  # include Changeable
  # TODO: Its probably best not to use this type directly.
  attr_accessible :name, :url, :user_id, :user
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :url
end
