class BookmarksController < ApplicationController

  def add_padlet
    mark = PadletBookmark.create_for_user(current_visitor)
    render :update do |page|
      page.replace_html "padlet_button",
        :partial => "bookmarks/padlet_bookmark/show",
        :locals => {:name => mark.name, :url => visit_bookmark_path(mark)}
    end
  end

  def add
    mark = GenericBookmark.new(params['generic_bookmark'])
    mark.user = current_visitor
    mark.save
    render :update do |page|
      page.replace_html "bookmark_form",
        :partial => "bookmarks/generic_bookmark/form"
      page.insert_html "before",
        "bookmark_form",
        :partial => "bookmarks/generic_bookmark/show",
        :locals => {:name => mark.name, :url => visit_bookmark_path(mark)}
    end
  end

  def visit
    mark = Bookmark.find(params['id'])
    mark.record_visit(current_visitor)
    redirect_to mark.url
  end
end