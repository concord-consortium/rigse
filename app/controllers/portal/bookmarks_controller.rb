class Portal::BookmarksController < ApplicationController
  include Portal::BookmarksHelper

  def index
    # This is needed so the side-menu selection works as expected.
    @portal_clazz = get_current_clazz
    @bookmarks = Portal::Bookmark.where(clazz_id: @portal_clazz)
    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['LINKS'])
  end

  def add_padlet
    mark = Portal::PadletBookmark.create_for_user(current_visitor, get_current_clazz)
    render :update do |page|
      page.insert_html :bottom,
        "bookmarks_box",
        :partial => "portal/bookmarks/show",
        :locals => {:bookmark => mark, :new_bookmark_id => mark.id}
    end
  end

  def add
    props = params['portal_generic_bookmark'] || {
      name: 'My bookmark',
      url: 'http://concord.org'
    }
    mark = Portal::GenericBookmark.new(props)
    mark.user = current_visitor
    mark.clazz = get_current_clazz
    mark.save!
    render :update do |page|
      page.insert_html :bottom,
        "bookmarks_box",
        :partial => "portal/bookmarks/show",
        :locals => {:bookmark => mark, :new_bookmark_id => mark.id}
    end
  end

  def visit
    mark = Portal::Bookmark.find(params['id'])
    mark.record_visit(current_visitor)
    redirect_to mark.url
  end

  def delete
    mark = Portal::Bookmark.find(params['id'])
    dom_id = bookmark_dom_item(mark)
    if mark.changeable? current_visitor
      mark.destroy
      render :update do |page|
        page.remove dom_id
        if Portal::PadletBookmark.user_can_make? current_visitor
          page.show "padlet_form"
        end
      end
    end
  end

  def sort
    ids = JSON.parse(params['ids'])
    bookmarks = ids.map { |i| Portal::Bookmark.find(i) }
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
    bookmark = Portal::Bookmark.find(params['id'])
    if bookmark && bookmark.changeable?(current_visitor)
      %w[name url is_visible].each do |param|
        unless params[param].blank?
          bookmark.update_attribute(param, params[param])
        end
      end
      if bookmark.save
        render :json => {
          id: bookmark.id,
          name: bookmark.name,
          url: bookmark.url,
          is_visible: bookmark.is_visible
        }
        return
      end
    end
    render :json => { failure: 'true' }, :status => :unprocessable_entity
  end

  def visits
    if current_visitor.has_role? "admin"
      @visits = Portal::BookmarkVisit.recent
      render :visits
    else
      redirect_to :home
    end
  end

  private

  def get_current_clazz()
    Portal::Clazz.includes(:offerings => :learners, :students => :user).find(params[:clazz_id])
  end
end