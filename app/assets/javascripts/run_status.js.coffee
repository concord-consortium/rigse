
class RunStatus
  constructor: (@buttonElem) ->
    @parse_offering_url(@buttonElem.href);
    @run_button_elm    = @buttonElem.up '.run_buttons'
    @run_status_elm    = @run_button_elm.next '.run_in_progress'
    @message_elm        = @run_status_elm.down '.message'
    @spinner_elm        = @run_status_elm.down '.wait_image'
    @showing_run_status = false

    if @run_button_elm and @run_status_elm
      @buttonElem.observe "click", (evt) =>
        # evt.preventDefault()
        @toggleRunStatusView()
        @trigger_status_updates()

  toggleRunStatusView: ->
    if @showing_run_status
      @showing_run_status = false
      @hide_run_status()
    else
      @showing_run_status = true
      @show_run_status()

  show_run_status: ->
    @run_button_elm.hide()
    @run_status_elm.show()

  hide_run_status: ->
    @run_button_elm.show()
    @run_status_elm.hide()
    clearInterval @interval_id if @interval_id
    @interval_id = null;

  parse_offering_url: (url) ->
    @offering_id = url.match(/\/offerings\/\d+/)[0]
    @offering_id = @offering_id.match(/\d+/)[0] if @offering_id

  update_status: (msg) ->
    @message_elm.update msg

  we_are_waiting: ->
    @message_elm.addClassName 'waiting'
    @message_elm.removeClassName 'ready'
    @spinner_elm.show()

  we_are_ready: ->
    @message_elm.addClassName 'ready'
    @message_elm.removeClassName 'waiting'
    @spinner_elm.hide()

  handle_error: (msg) ->
    @message_elm.update msg

  stop_status_updates: ->
    @update_status 'completed'
    @hide_run_status()

  trigger_status_updates: ->
    if @interval_id  != null
      clearInterval(@interval_id)
      @interval_id = null
    @we_are_waiting();
    update_status = () =>
      new Ajax.Request('/portal/offerings/' + @offering_id + '/launch_status.json',
        method: 'get'
        onSuccess: (transport) =>
          status_event = transport.responseJSON
          if (!!status_event.event_details)
            @update_status(status_event.event_details);
          if (!!status_event && status_event.event_type == "activity_otml_requested")
            @we_are_ready()
          if (!!status_event && (status_event.event_type == "no_session" || status.event_type == "bundle_saved"))
            @stop_status_updates()
        onFailure: ->
          @handle_error "launch status failure"
        )
    @update_status("Requesting activity launcher...")
    @interval_id = setInterval(update_status,5000)

document.observe "dom:loaded", ->
  $$("a.button.run.solo").each (item) ->
    runstatus = new RunStatus(item)
  # There used to be code like:
  # $$("a.button.run.in_group").each (item) ->
  #   (...)
  # However now run status will be started by AngularJS code that handles
  # collaboration setup. See: angular/collaboration.js.coffee

# Expose RunStatus to global namespace as OfferingRunStatus.
window.OfferingRunStatus = RunStatus

