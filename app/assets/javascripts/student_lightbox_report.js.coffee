# Decorate the links with the class correct class names.
# hide and show the report view.
# handle the escape key button presses.

class LightboxReport

  constructor: (@link_elm) ->
    @parseOfferingUrl(@link_elm.href);
    @lightbox_elm = $('lightbox_wrapper')
    @report_dom   = 'report'
    @report_elm   = $(@report_dom)
    @close_elm    = $('lightbox_closer')    
    @interval_id  = null
    @enableEvents()

  enableEvents: ->
    # disable any lingering events:
    $(document).stopObserving 'keydown'
    @close_elm.stopObserving  'click'
    @link_elm.stopObserving   'click'

    $(document).observe 'keydown', (evt) =>
      @handleKedown(evt)

    @close_elm.observe "click", (evt) =>
      @hideLightBox();

    @link_elm.observe "click", (evt) =>
      evt.preventDefault()
      @showLightBox()

  updateReport: ->
    new Ajax.Updater(@report_dom, @report_url)

  enableUpdates: ->
    @disableUpdates()  # remove old intervals
    @updateReport()
    update_func = =>
      @updateReport()
    @interval_id = setInterval(update_func, 10000)

  disableUpdates: ->
    if @interval_id
      clearInterval(@interval_id)
      @interval_id = null

  showLightBox: ->
    @enableUpdates()
    @lightbox_elm.show()

  hideLightBox: ->
    @disableUpdates()
    @lightbox_elm.hide()

  parseOfferingUrl: (url) ->
    @report_url = url.match(/\/portal\/offerings\/\d+\/student_report/gi).first();
    if @report_url?
      @offering_id = @report_url.match(/\d+/gi).first()
    
  handleKedown: (e) ->
    if (e.keyCode)    
      code = e.keyCode
    else if (e.which) 
      code = e.which
    switch code
      when 27
        @hideLightBox()


document.observe "dom:loaded", ->
  $$(".lightbox_report_link>a").each (item) ->
    reporter = new LightboxReport(item)
