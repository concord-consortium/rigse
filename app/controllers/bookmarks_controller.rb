class BookmarksController < ApplicationController
  include BookmarksHelper

  def add_padlet
    mark = PadletBookmark.create_for_user(current_visitor)
    render :update do |page|
      # page.hide "padlet_form"  # no more limit of 1 per user...
      page.insert_html :bottom,
        "bookmarks_box",
        :partial => "bookmarks/show",
        :locals => {:bookmark => mark}
    end
  end

  def add
    mark = GenericBookmark.new(params['generic_bookmark'])
    mark.user = current_visitor
    if mark.save
      render :update do |page|
        page.replace_html "bookmark_form",
          :partial => "bookmarks/generic_bookmark/form"
        page.insert_html :bottom,
          "bookmarks_box",
          :partial => "bookmarks/show",
          :locals => {:bookmark => mark}
      end
    else
      render :nothing => true
    end
  end

  def visit
    mark = Bookmark.find(params['id'])
    mark.record_visit(current_visitor)
    redirect_to mark.url
  end

  def delete
    mark = Bookmark.find(params['id'])
    dom_id = bookmark_dom_item(mark)
    if mark.changeable? current_visitor
      mark.destroy
      render :update do |page|
        page.remove dom_id
        if PadletBookmark.user_can_make? current_visitor
          page.show "padlet_form"
        end
      end
    end
  end

  def visits
    if current_visitor.has_role? "admin"
      @visits = BookmarkVisit.recent
      render :index
    else
      redirect_to :home
    end
  end
end