class BookmarksController < ApplicationController

  def add_padlet
    mark = PadletBookmark.create_for_user(current_visitor)
    render :update do |page|
      page.replace_html "padlet_button",
        :partial => "bookmarks/padlet_bookmark/show",
        :locals => {:name => mark.name, :url => mark.url}
    end
  end
  def add_bookmark
    mark = GenericBookmark.create(params['generic_bookmark'])
    render :update do |page|
      page.replace_html "bookmark_form",
        :partial => "bookmarks/generic_bookmark/form"
      page.insert_html "before",
        "bookmark_form",
        :partial => "bookmarks/generic_bookmark/show",
        :locals => {:name => mark.name, :url => mark.url }
    end
  end
end