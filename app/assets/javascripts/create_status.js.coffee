
class CreateStatus
  constructor: (@parentElem, registerListener=true) ->
    @link_elm          = @parentElem.down 'input'
    @create_status_elm = @parentElem.down '.create_in_progress'

    if @link_elm and @create_status_elm and registerListener
      @link_elm.observe "click", (evt) =>
        @hideButton()

  hideButton: ->
    @link_elm.hide()
    @create_status_elm.show()

  showButton: ->
    @link_elm.show()
    @create_status_elm.hide()

window.CreateStatus = CreateStatus

document.observe "dom:loaded", ->
  $$(".create_button").each (item) ->
    createstatus = new CreateStatus(item)

