class ProgressDisclosure
  constructor: (@disclosure_elem) ->
    @details_elms     = @disclosure_elem.up('table').select('tr.details')
    @showing_details = false
    @toggleDetailView();

    @disclosure_elem.observe "click", (evt) =>
      evt.preventDefault()
      @toggleDetailView()

  toggleDetailView: ->
    if @showing_details
      @showing_details = false
      @hideDetails()
      @showClosedDisclosure()
    else
      @showing_details = true
      @showDetails()
      @showOpenedDisclosure()

  showOpenedDisclosure: ->
    @disclosure_elem.update('▶')
  
  showClosedDisclosure: ->
    @disclosure_elem.update('▼')
  
  showDetails: ->
    @details_elms.each (elm) -> 
      elm.hide()

  hideDetails: ->
    @details_elms.each (elm) ->
      elm.show()    

document.observe "dom:loaded", ->
  $$(".disclosure_widget").each (item) ->
    reporter = new ProgressDisclosure(item)