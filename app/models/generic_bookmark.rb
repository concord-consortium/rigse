class GenericBookmark < Bookmark
  default_scope :order => 'position'
  acts_as_list
end