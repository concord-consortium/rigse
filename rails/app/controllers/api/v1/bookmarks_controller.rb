class API::V1::BookmarksController < API::APIController

  skip_before_filter :verify_authenticity_token

  # POST api/v1/bookmarks
  def create
    auth = check_auth(params)
    return error(auth[:error]) if auth[:error]

    name = params[:name] || 'My bookmark'
    url = params[:url] || 'http://concord.org'

    bookmark = Portal::GenericBookmark.new({name: name, url: url})
    bookmark.user = auth[:user]
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
    auth = check_auth(params)
    return error(auth[:error]) if auth[:error]

    bookmark = Portal::Bookmark.find_by_id(params['id'])
    if !bookmark
      return error('Invalid bookmark id')
    end

    if bookmark && bookmark.changeable?(auth[:user])
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
    auth = check_auth(params)
    return error(auth[:error]) if auth[:error]

    bookmark = Portal::Bookmark.find_by_id(params['id'])
    if !bookmark
      return error('Invalid bookmark id')
    end
    if !bookmark.changeable?(auth[:user])
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
    auth = check_auth(params)
    return error(auth[:error]) if auth[:error]

    ids = JSON.parse(params['ids'])
    bookmarks = ids.map { |i| Portal::Bookmark.find(i) }
    position = 0
    bookmarks.each do |bookmark|
      if bookmark.changeable?(auth[:user])
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

  def check_auth(params)
    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return {error: e.message}
    end

    begin
      jwt = get_jwt(params)
      claims = jwt && jwt[:data] ? jwt[:data]["claims"] : nil

      if !claims || !claims["edit_bookmarks"]
        raise StandardError, 'You are not authorized to edit bookmarks'
      end

      clazz_id = claims["clazz_id"]
      if !clazz_id
        raise StandardError, 'Missing clazz_id claim'
      end

      portal_class = Portal::Clazz.find_by_id(clazz_id)
      if !portal_class
        raise StandardError, 'Invalid clazz_id claim'
      end

      if !user.portal_teacher || !user.portal_teacher.has_clazz?(portal_class)
        raise StandardError, 'You are not authorized to edit bookmarks for this class'
      end

      return {user: user, portal_class: portal_class, error: nil}

    rescue StandardError => e
      return {error: e.message}
    end
  end
end
