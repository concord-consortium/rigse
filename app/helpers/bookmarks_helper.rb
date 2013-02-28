module BookmarksHelper

  def bookmarks
    types = Admin::Project.default_project.enabled_bookmark_types
    Bookmark.find_all_by_user_id(current_visitor).select do |mark|
      types.include? mark.type
    end
  end

  def render_all_bookmarks
    return if Admin::Project.default_project.enabled_bookmark_types.empty?
    haml_tag "#bookmarks_box" do
      haml_tag "p", :style => "padding: 10px 0px 0px 10px; font-weight: bold;" do
        haml_concat("Bookmarks:")
      end
      bookmarks.each do |bookmark|
        render_bookmark bookmark
      end
    end
  end

  def render_bookmark(bookmark)
    concat(render(:partial => "bookmarks/show", :locals => {
      :bookmark => bookmark
    }))
  end

  def render_add_bookmark_form
    types = Admin::Project.default_project.enabled_bookmark_types
    clazzes = types.map {|t|t.safe_constantize}.compact
    clazzes.each do |claz|
      type = claz.name.underscore
      if (claz.respond_to? :user_can_make?) && claz.user_can_make?(current_visitor)
        bookmark = claz.new
        haml_tag '.bookmarks_form' do
          haml_concat(render(:partial => "bookmarks/#{type}/form", :locals => {
          :bookmark => bookmark}))
        end
      end
    end
  end

  def delete_bookmark_button(mark)
    name    = mark.name
    url     = delete_bookmark_path(mark)
    confirm = "delete bookmark to #{name}"

    link_to_remote( "x",
      {:confirm => confirm,  :url => url},
      {:class => "delete"}
    )
  end

  def bookmark_dom_item(mark)
    "bookmark_#{mark.type}_#{mark.id}"
  end

end
