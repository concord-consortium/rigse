module BookmarksHelper

  def bookmarks
    Bookmark.find_all_by_user_id(current_visitor)
  end

  def render_all_bookmarks
    bookmarks.each do |bookmark|
      render_bookmark bookmark
    end
  end

  def render_bookmark(bookmark,form='show')
    type = bookmark.type.underscore
    concat(render(:partial => "bookmarks/#{type}/#{form}", :locals => {
      :name => bookmark.name,
      :url  => visit_bookmark_path(bookmark)
    }))
  end

  def render_add_bookmark_form
    types = Admin::Project.default_project.enabled_bookmark_types
    clazzes = types.map {|t|t.safe_constantize}.compact
    clazzes.each do |claz|
      type = claz.name.underscore
      if (claz.respond_to? :user_can_make?) && claz.user_can_make?(current_visitor)
        bookmark = claz.new
        concat(render(:partial => "bookmarks/#{type}/form", :locals => {
          :bookmark => bookmark}))
      end
    end
  end


end
