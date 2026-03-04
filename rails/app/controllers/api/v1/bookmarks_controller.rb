class API::V1::BookmarksController < API::APIController

  before_action :require_api_user!

  # POST api/v1/bookmarks
  def create
    auth = authorize_class_teacher!(params)
    return error(auth[:error]) if auth[:error]

    name = params[:name] || 'My bookmark'
    url = params[:url] || 'http://concord.org'

    bookmark = Portal::GenericBookmark.new({name: name, url: url})
    bookmark.user = current_user
    bookmark.clazz = auth[:portal_class]
    authorize bookmark

    if bookmark.save
      render_bookmark(bookmark)
    else
      error('Unable to create bookmark!')
    end
  end

  # PUT api/v1/bookmarks
  def update
    auth = authorize_class_teacher!(params)
    return error(auth[:error]) if auth[:error]

    bookmark = Portal::Bookmark.find_by_id(params['id'])
    if !bookmark
      return error('Invalid bookmark id')
    end

    if bookmark && bookmark.changeable?(current_user)
      %w[name url is_visible].each do |param|
        if params.has_key?(param)
          bookmark.update_attribute(param, params[param])
        end
      end
      if bookmark.save
        return render_bookmark(bookmark)
      else
        return error('Unable to update the bookmark')
      end
    else
      return error('You are not authorized to update the bookmark')
    end
  end

  # DELETE api/v1/bookmarks
  def destroy
    auth = authorize_class_teacher!(params)
    return error(auth[:error]) if auth[:error]

    bookmark = Portal::Bookmark.find_by_id(params['id'])
    if !bookmark
      return error('Invalid bookmark id')
    end
    if !bookmark.changeable?(current_user)
      return error('You are not authorized to delete the bookmark')
    end

    if bookmark.destroy()
      return render_ok()
    else
      return error('Unable to delete the bookmark')
    end
  end

  # POST api/v1/bookmarks/sort
  def sort
    auth = authorize_class_teacher!(params)
    return error(auth[:error]) if auth[:error]

    ids = params['ids']
    if !ids
      return error("Missing ids parameter")
    end

    bookmarks = ids.map { |i| Portal::Bookmark.find(i) }
    position = 1
    bookmarks.each do |bookmark|
      if bookmark.changeable?(current_user)
        bookmark.position = position
        position = position + 1
        bookmark.save
      end
    end
    render_ok()
  end

  private

  def render_ok
    render :json => { success: true }, :status => :ok
  end

  def render_bookmark(bookmark)
    render :json => {
      success: true,
      data: {
        id: bookmark.id,
        name: bookmark.name,
        url: bookmark.url,
        is_visible: bookmark.is_visible
      }
    }, :status => :ok
  end

  def authorize_class_teacher!(params)
    clazz_id = params["clazz_id"]
    if !clazz_id
      return {error: 'Missing clazz_id param'}
    end

    portal_class = Portal::Clazz.find_by_id(clazz_id)
    if !portal_class
      return {error: 'Invalid clazz_id param'}
    end

    if !current_user.portal_teacher || !current_user.portal_teacher.has_clazz?(portal_class)
      return {error: 'You are not authorized to edit bookmarks for this class'}
    end

    return {portal_class: portal_class, error: nil}
  end
end
