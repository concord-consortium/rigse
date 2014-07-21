class GenericBookmark < Bookmark
  default_scope :order => 'position'
end