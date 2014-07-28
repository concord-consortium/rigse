module Portal::BookmarksHelper

  def enabled_bookmark_types
    Portal::Bookmark.allowed_types_raw
  end

  def bookmarks_enabled
    enabled_bookmark_types.size > 0
  end

  def bookmarks
    types = enabled_bookmark_types
    Portal::Bookmark.find_all_by_user_id(current_visitor).select do |mark|
      types.include? mark.type
    end
  end

  def each_available_claz
    clazzes = enabled_bookmark_types.map {|t|t.safe_constantize}.compact
    clazzes.each do |claz|
      if (claz.respond_to? :user_can_make?) && claz.user_can_make?(current_visitor)
        type = claz.name.demodulize.underscore
        yield claz, type
      end
    end
  end

  def render_add_bookmark_buttons
    each_available_claz do |claz, type|
      haml_tag '.add_bookmark_button' do
        haml_concat(render(:partial => "portal/bookmarks/#{type}/button"))
      end
    end
  end

  def bookmark_dom_item(mark)
    "bookmark_#{mark.type}_#{mark.id}"
  end
end
