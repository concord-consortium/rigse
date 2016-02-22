# Decorate the links with the class correct class names.
# hide and show the report view.
# handle the escape key button presses.

trim = (string) ->
  return string.replace(/^\s+|\s+$/g,'');

class Anonymizer

  constructor: (offeringUrl, anonymizeOnInit) ->
    @offeringUrl = offeringUrl
    @selector      = ".learner_response_name"
    @alt_selector  = "div.user"
    @feedback_selector = "div.feedback_link"
    @title_selector = "img.portray"
    @button_select = "anonymize_button"
    @real_to_fake_map  = {}
    @fake_to_real_map  = {}
    @counter = 0;
    @anonymous  = false;
    if $(@button_select)
      $(@button_select).observe 'click', (evt) =>
        @toggle()
        evt.stop();
    $$(@selector).each (item) =>
      real_name = trim(item.textContent)
      if not @real_to_fake_map[real_name]
        fake = "Student #{@counter++}"
        @real_to_fake_map[real_name] = fake
        @fake_to_real_map[fake] = real_name

    if anonymizeOnInit
      $(@button_select).textContent = "Show names"
      @anonymize()

  publicize: () ->
    @anonymous = false
    $$(@selector).each (item) =>
      item.textContent = @fake_to_real_map[trim(item.textContent)]
    $$(@alt_selector).each (item) =>
      item.textContent = @fake_to_real_map[trim(item.textContent)]
    $$(@title_selector).each (item) =>
      item.title = @fake_to_real_map[trim(item.title)]
    $$(@feedback_selector).each (Element.show)

  anonymize: ->
    @anonymous = true
    $$(@selector).each (item) =>
      item.textContent = @real_to_fake_map[trim(item.textContent)]
    $$(@alt_selector).each (item) =>
      item.textContent = @real_to_fake_map[trim(item.textContent)]
    $$(@title_selector).each (item) =>
      item.title = @real_to_fake_map[trim(item.title)]
    $$(@feedback_selector).each (Element.hide)

  toggle: ->
    $(@button_select).textContent = if @anonymous
      @publicize()
      "Hide names"
    else
      @anonymize()
      "Show names"
    @saveSetting()

  saveSetting: ->
    jQuery.ajax
      url: @offeringUrl
      type: 'PUT'
      data: 'offering[anonymous_report]': @anonymous

window.Anonymizer = Anonymizer
