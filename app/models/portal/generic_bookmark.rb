class Portal::GenericBookmark < Portal::Bookmark
  default_scope :order => 'position'
end