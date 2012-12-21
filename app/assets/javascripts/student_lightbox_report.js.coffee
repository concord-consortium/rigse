# Decorate the links with the class correct class names.
# hide and show the report view.
# handle the escape key button presses.

class LightboxReport

  constructor: (@link_elm) ->
    @parseOfferingUrl(@link_elm.href);
    @lightbox_elm = $('lightbox_wrapper')
    @report_dom   = 'lightbox_report'
    @report_elm   = @report_dom

    @link_elm.observe "click", (evt) =>
      evt.preventDefault()
      @showLightBox()
      @updateReport()


  updateReport: ->
    new Ajax.Updater(@report_dom, @report_url);

  showLightBox: ->
    @lightbox_elm.show()

  hideLightBox: ->
    @lightbox_elm.hide()

  parseOfferingUrl: (url) ->
    @report_url = url.match(/\/portal\/offerings\/\d+\/student_report/gi).first();
    if jnlp_url?
      @offering_id = @report_url.match(/\d+/gi).first();
    
document.observe "dom:loaded", ->
  $$(".lightbox_report_link>a").each (item) ->
    reporter = new LightboxReport(item)