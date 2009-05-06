var default_duration = 0.2;
var open_class = 'accordion_toggle_active';
var closed_class = 'accordion_toggle';
var element_for_toggle = function(toggle_element) { return $(toggle_element).next('ul'); }
var id_for_toggle = function(toggle_element)      { return $(toggle_element).up().identify();   }
var has_cookie = function(toggle_element)         { return (readCookie(id_for_toggle(toggle_element)) == "true");    }
var set_cookie = function(toggle_element)         { createCookie(id_for_toggle(toggle_element),'true'); }
var remove_cookie = function(toggle_element)      { eraseCookie(id_for_toggle(toggle_element)); }
var is_on = function(toggle_element) { return toggle_element.hasClassName(open_class); }

var turn_on = function(toggle_element,duration) { 
  toggle_element.addClassName(open_class);
  toggle_element.removeClassName(closed_class);
  Effect.BlindDown(element_for_toggle(toggle_element),{ duration: duration });  
}

var turn_off = function(toggle_element,duration) {
  toggle_element.addClassName(closed_class);
  toggle_element.removeClassName(open_class);
  Effect.BlindUp(element_for_toggle(toggle_element),{ duration: duration });  
}

var toggle = function(event) {
  toggle_element = event.element()
  if (is_on(toggle_element)) {
    turn_off(toggle_element,default_duration);
    remove_cookie(toggle_element);
  }
  else {
    turn_on(toggle_element,default_duration);
    set_cookie(toggle_element);
  }
}

document.observe('dom:loaded', function() {
  $$("." + closed_class).each(function(element){
    element.observe('click',toggle);
    turn_off(element,0);
    if (has_cookie(element)) {
      turn_on(element,0);
    }
  });
})
