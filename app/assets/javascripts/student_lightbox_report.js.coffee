
# Decorate the links with the class correct class names.
# hide and show the report view.
# handle the escape key button presses.

class LightboxReport

  constructor: (@offering_id) ->
    @lightbox_dom = 'please_wait'
    @report_dom   = 'please_wait_report'
    @report_url   = '/portal/offerings/' + @offering_id +'/student_report.html'

  updateReport: ->
    @showLightBox()
    new Ajax.Updater(@report_dom, @report_url);

  showLightBox: ->
    $(@lightbox_dom).show()

  hideLightBox: ->
    $(@lightbox_dom).hide()

  parseOfferingUrl: (url) ->
    if (url.match(/portal\/offerings\/\d+\.jnlp/gi))
      @offering_id = url.match(/\d+\.jnlp/gi).first();
      @offering_id = offering_id.match(/\d+/gi).first();
    
document.observe "dom:loaded", ->
  $$(".lightbox_report_link").each(function(item) {
    if(item.hasClassName('offering')){
      var offering_id = ParseOfferingUrl(item.href);
      item.observe("click", function(e){
        showWait(offering_id);
      });
    } else {
      item.observe("click", showWait);
    }
  });
});