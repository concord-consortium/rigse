class Portal::BookmarksController < ApplicationController
  include Portal::BookmarksHelper

  def index
    @portal_clazz = get_current_clazz

    #
    # Create a tmp bookmark to perform pundit auth check.
    #
    mark = Portal::GenericBookmark.new()
    mark.user = current_user
    mark.clazz = @portal_clazz
    authorize mark

    @bookmarks = Portal::Bookmark.where(clazz_id: @portal_clazz).select([:id, :is_visible, :name, :position, :url])
    @jwt = SignedJWT::create_portal_token(current_user, {
      claims: {
        edit_bookmarks: true,
        clazz_id: @portal_clazz.id
      }
    }, 3600)

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
end
