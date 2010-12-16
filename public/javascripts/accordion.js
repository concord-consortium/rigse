/*globals $ $$ createCookie readCookie eraseCookie Effect document window */
(function() {
  var default_duration = 0.2;
  var accordion_toggle_class = 'accordion_toggle';
  var open_class = 'accordion_toggle_open';
  var closed_class = 'accordion_toggle_closed';
  var show_hide_class = 'accordion_show_hide_text';
  var element_for_toggle = function(toggle_element) { return $(toggle_element).next('.accordion_content'); };
  var id_for_toggle = function(toggle_element)      { return $(toggle_element).up().identify();   };
  var has_cookie = function(toggle_element)         { return (readCookie(id_for_toggle(toggle_element)) == "true");    };
  var set_cookie = function(toggle_element)         { createCookie(id_for_toggle(toggle_element),'true'); };
  var remove_cookie = function(toggle_element)      { eraseCookie(id_for_toggle(toggle_element)); };
  var is_on = function(toggle_element) { return toggle_element.hasClassName(open_class); };
  var is_a_toggle = function(elm) { return (elm.hasClassName(open_class) || elm.hasClassName(closed_class)) ; };
  var is_show_hide = function(elm) { return (elm.hasClassName(show_hide_class)); };
  
  var turn_on = function(toggle_element,duration) { 
    toggle_element.addClassName(open_class);
    toggle_element.removeClassName(closed_class);
    var show_hider = $(toggle_element).down("." + show_hide_class);
    if (show_hider) {
      show_hider.update(show_hider.innerHTML.replace('Show','Hide'));
      show_hider.update(show_hider.innerHTML.replace('show','Hide'));
    }
    Effect.BlindDown(element_for_toggle(toggle_element),{ duration: duration });  
  };

  var turn_off = function(toggle_element,duration) {
    toggle_element.addClassName(closed_class);
    toggle_element.removeClassName(open_class);
    var show_hider = $(toggle_element).down("." + show_hide_class);
    if (show_hider) {
      show_hider.update(show_hider.innerHTML.replace('Hide','Show'));
      show_hider.update(show_hider.innerHTML.replace('hide','Show'));
    }
    Effect.BlindUp(element_for_toggle(toggle_element),{ duration: duration });
  };
  
  var toggle = function(event) {
    var toggle_element = event.element();
    if (is_show_hide(toggle_element)) {
      toggle_element = toggle_element.up("." + accordion_toggle_class);
    }
    if (toggle_element) {
      if(is_a_toggle(toggle_element)) {
        if (is_on(toggle_element)) {
          turn_off(toggle_element,default_duration);
          remove_cookie(toggle_element);
        }
        else {
          turn_on(toggle_element,default_duration);
          set_cookie(toggle_element);
        }
        event.stop();
      }
    }
  };


  document.observe('dom:loaded', function() {
    $$("." + closed_class).each(function(element){
      // turn_off(element,0);
      if (has_cookie(element)) {
        turn_on(element,0);
      }
    });
  });

  document.observe('click',toggle);
}());
