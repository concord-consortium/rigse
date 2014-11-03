InstanceCounter    = 0;
CollectionsDomID   = "bookmarks_box"
CollectionSelector = "##{CollectionsDomID}"
ItemSelector       = "#{CollectionSelector} .bookmark_item"

SortHandle         = "slide"
SortUrl            = "/portal/bookmarks/sort"
EditUrl            = "/portal/bookmarks/edit"

bookmark_identify = (div) ->
  div.readAttribute('data-bookmark-id');

class Bookmark
  constructor:(@div, @manager) ->
    @id               = bookmark_identify(@div)
    @editor           = @div.select('div.editor')[0]
    @edit_button      = @div.select('a.edit')[0]
    @link_div         = @div.select('a.link_text')[0]
    @save_button      = @div.select('button.save')[0]
    @name_field       = @div.select('input[name="name"]')[0]
    @url_field        = @div.select('input[name="url"]')[0]
    @is_visible_field = @div.select('input[name="is_visible"]')[0]

    @editor_active = false
    @is_visible_field.observe 'change', (evt) =>
      @saveVisibility()
    @save_button.observe 'click', (evt) =>
      @saveForm()
    @edit_button.observe 'click', (evt) =>
      if @editor_active
        @edit(false)
      else
        @manager.editBookmark(@id)

  edit: (v) ->
    if v
      @editor.show()
      @link_div.hide()
      @name_field.focus()
    else
      @editor.hide()
      @link_div.show()
    @editor_active = v

  update: (new_name, new_url, new_visibility) ->
    @link_div.update(new_name)
    @link_div.writeAttribute('href', new_url)
    @name_field.setValue(new_name)
    @url_field.setValue(new_url)
    @is_visible_field.setValue(new_visibility)

  saveForm: ->
    @edit(false)
    new_name = @name_field.getValue()
    new_url = @url_field && @url_field.getValue()
    @sendEditReq(
      id: @id
      name: new_name
      url: new_url
    )

  saveVisibility: ->
    new_visibility = @is_visible_field.getValue() == 'true'
    @sendEditReq(
      id: @id
      is_visible: new_visibility
    )

  sendEditReq: (params) ->
    new Ajax.Request EditUrl,
      method: 'post',
      parameters: params
      requestHeaders:
        Accept: 'application/json'
      onSuccess: (transport) =>
        json = transport.responseText.evalJSON(true)
        @update(json.name, json.url, json.is_visible)
      onFailure: (transport) =>
        alert "Bookmark update failed. Please reload the page and try again."
        @div.highlight(startcolor: '#ff0000')

class BookmarksManager
  constructor: ->
    @bookmarks = {}
    @addBookmarks()

  addBookmarks: ->
    $$(ItemSelector).each (item) =>
      @bookmarkForDiv(item)
    Sortable.create CollectionsDomID,
      'tag'     : 'div'
      'handle'  : SortHandle
      'onUpdate': (divs) => @orderChanged(divs)

  bookmarkForDiv: (div) ->
    id = bookmark_identify(div)
    @bookmarks[id] ||= new Bookmark(div, @)

  editBookmark: (id) ->
    @bookmarks[id].edit(true)
    for own idx, mark of @bookmarks
      if Number(idx) != Number(id)
        mark.edit(false)
    return

  orderChanged:(divs) ->
    results = $$(ItemSelector).map (div) =>
      @bookmarkForDiv(div).id
    @changeOrder(results)

  changeOrder:(array_of_ids) ->
    new Ajax.Request SortUrl,
      method: 'post',
      parameters:
        ids: Object.toJSON(array_of_ids)
      requestHeaders:
        Accept: 'application/json'
      onSuccess: (transport) ->
        # do nothing
      onFailure: (transport) ->
        alert "Bookmark reorder failed. Please reload the page and try again."
        $$(ItemSelector).each (item) =>
          item.highlight(startcolor: '#ff0000')

  bookmarkRequestStarted: (button_id, msg) ->
    @setElemEnabled(button_id, false)
    startWaiting(msg)

  bookmarkRequestFinished: (button_id) ->
    @setElemEnabled(button_id, true)
    stopWaiting()

  bookmarkRequestFailed: ->
    alert('Bookmark creation failed. Please reload the page and try again.');

  setElemEnabled: (element_id, val) ->
    elem = $(element_id)
    if val
      elem.style.opacity = 1
      elem.enable()
    else
      elem.style.opacity = 0.2
      elem.disable()

document.observe "dom:loaded", ->
  window.bookmarksManager = new BookmarksManager() if $$(CollectionSelector).length
