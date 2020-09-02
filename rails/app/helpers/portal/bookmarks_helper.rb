module Portal::BookmarksHelper

  def bookmarks_enabled
    Portal::Bookmark.allowed_types.size > 0
  end

  def each_available_claz
    clazzes = Portal::Bookmark.allowed_types.compact
    clazzes.each do |claz|
      if (claz.respond_to? :user_can_make?) && claz.user_can_make?(current_visitor)
        type = claz.name.demodulize.underscore
        yield claz, type
      end

    end
  end

end
