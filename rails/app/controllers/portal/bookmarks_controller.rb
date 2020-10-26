class Portal::BookmarksController < ApplicationController
  include Portal::BookmarksHelper

  def index
    @portal_clazz = get_current_clazz

    #
    # Create a tmp bookmark to perform pundit auth check.
    #
    mark = Portal::GenericBookmark.new() # strong params not required
    mark.user = current_user
    mark.clazz = @portal_clazz
    authorize mark

    @bookmarks = Portal::Bookmark.where(clazz_id: @portal_clazz).select([:id, :is_visible, :name, :position, :url])

    # Save the left pane sub-menu item
    Portal::Teacher.save_left_pane_submenu_item(current_visitor, Portal::Teacher.LEFT_PANE_ITEM['LINKS'])
  end

  def visit
    mark = Portal::Bookmark.find(params['id'])
    mark.record_visit(current_visitor)
    redirect_to mark.url
  end

  def visits
    if current_visitor.has_role? "admin"
      @visits = Portal::BookmarkVisit.recent
      render :visits
    else
      redirect_to :root
    end
  end

  private

  def get_current_clazz()
    Portal::Clazz.includes(:offerings => :learners, :students => :user).find(params[:clazz_id])
  end

  def portal_generic_bookmark_strong_params(params)
    params.permit(:clazz_id, :is_visible, :name, :position, :type, :url, :user_id)
  end
end
