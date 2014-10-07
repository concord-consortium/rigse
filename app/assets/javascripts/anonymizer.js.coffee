# Decorate the links with the class correct class names.
# hide and show the report view.
# handle the escape key button presses.

trim = (string) ->
  return string.replace(/^\s+|\s+$/g,'');

class Anonymizer

  constructor: ->
    @selector      = ".learner_response_name"
    @alt_selector  = "div.user"
    @button_select = "anonymize_button"
    @real_to_fake_map  = {}
    @fake_to_real_map  = {}
    @counter = 0;
    @anonymous  = false;
    if $(@button_select)
      $(@button_select).observe 'click', (evt) =>
        @toggle()
        evt.stop();

  record_fake_and_real: (real_name) ->
    fake = @real_to_fake_map[real_name]
    unless fake
      fake = "Student #{@counter}"
      @counter++
      @real_to_fake_map[real_name] = fake
      @fake_to_real_map[fake] = real_name
    return fake

  rename_button: ->
    if @anonymous
      $(@button_select).textContent = "Show names"
    else
      $(@button_select).textContent = "Hide names"

  publicize: ->
    @anonymous = false
    $$(@selector).each (item) =>
      fake_name = trim(item.textContent)
      item.textContent = @fake_to_real_map[fake_name]
    $$(@alt_selector).each (item) =>
      fake_name = trim(item.textContent)
      item.textContent = @fake_to_real_map[fake_name]

  anonymize: ->
    @anonymous = true
    $$(@selector).each (item) =>
      real_name = trim(item.textContent)
      item.textContent = @record_fake_and_real(real_name)
    $$(@alt_selector).each (item) =>
      real_name = trim(item.textContent)
      item.textContent = @real_to_fake_map[real_name]

  toggle: ->
    if @anonymous
      @publicize()
    else
      @anonymize()
    @rename_button()

document.observe "dom:loaded", ->
  a = new Anonymizer
