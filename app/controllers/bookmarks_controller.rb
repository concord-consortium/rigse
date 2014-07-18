class BookmarksController < ApplicationController
  include BookmarksHelper

  def index
    @bookmarks = bookmarks
    @portal_clazz = Portal::Clazz.includes(:offerings => :learners, :students => :user).find(params[:clazz_id])
    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['LINKS'])
  end

  def add_padlet
    mark = PadletBookmark.create_for_user(current_visitor)
    render :update do |page|
      page.insert_html :bottom,
        "bookmarks_box",
        :partial => "bookmarks/show",
        :locals => {:bookmark => mark, :adding => true}
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
          :locals => {:bookmark => mark, :adding => true}
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

  def sort
    ids = JSON.parse(params['ids'])
    bookmarks = ids.map { |i| Bookmark.find(i) }
    position = 0
    bookmarks.each do |bookmark|
      if bookmark.changeable? current_visitor
        bookmark.position = position
        position = position + 1
        bookmark.save
      end
    end
    render :nothing => true
  end

  def edit
    bookmark = Bookmark.find(params['id'])
    if bookmark && bookmark.changeable?(current_visitor)
      %w[name url].each do |param|
        unless params[param].blank?
          bookmark.update_attribute(param,params[param])
        end
      end
      if bookmark.save
        render :json => {
          id: bookmark.id,
          name: bookmark.name,
          url: bookmark.url
        }
        return
      end
    end
    render :json => { failure: 'true' }, :status => :unprocessable_entity
  end

  def visits
    if current_visitor.has_role? "admin"
      @visits = BookmarkVisit.recent
      render :visits
    else
      redirect_to :home
    end
  end
end