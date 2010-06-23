/*******************************
Some global helper functions:
*******************************/
debug = function (message) {
  if(console && typeof console.log != 'undefined') {
    console.log(message);
  }
}

css_attr = function(selector,attr) {
  $$(selector).each(
    function(elem) {
      debug(elem.getStyle(attr));
    }
  );
}

zindex = function(selector) {
  css_attr(selector,'z-index');
}

auth_token = function () {
  if (typeof(AUTH_TOKEN) == "undefined") {
    return false;
  }
  return AUTH_TOKEN;
}

flatten_sortables = function() {
  $$('.sortable').each(
    function(i) {
      i.setStyle({zIndex: 'auto'});
    }
  );
}

// take a extended dom_element and return a model name and id
decode_model = function(elem) {
  var dom_id = elem.identify() 
  var match = dom_id.gsub(/(.*)_([0-9]+)/, function(match){
    return match;
  });
  var matches = match.split(",");
  return {type:matches[1], id: matches[2]};
 }


focus_first_field = function() {
  // This will only work if there is one and only one 
  // form in the document... there is probably a better way..
  if (document.forms.size ==1) {
    var first_form = document.forms[0];
    var inputs = first_form.getInputs('text');
    if (inputs && inputs[0]) {
      inputs[0].activate();
    }
  }
}

dropdown_for = function(menu_dom_id,drop_down_dom_id) {
  var menu = $(menu_dom_id);
  var drop_down = $(drop_down_dom_id);
  var menu_width = menu.getDimensions().width
  var drop_down_width = drop_down.getDimensions().width
  var padding = 0;
  drop_down.hide();
  drop_down.show();
  drop_down.setStyle({'z-index': 2000});
  drop_down.setStyle({'padding' : padding + "px"})
    
  if (drop_down_width < menu_width) {
    drop_down.setStyle({
      width: menu_width+"px"
    }); 
    drop_down_width = menu_width;
  }
  
  var left_offset = (drop_down_width - menu_width) / -2
  var top_offset = menu.getDimensions().height - padding
  var options = { setWidth: false, setHeight: false, offsetLeft:left_offset, offsetTop: top_offset};

  drop_down.clonePosition(menu,options);
  

  drop_down.observe('mouseout', function(event) {
    var mouse_over_element = event.relatedTarget;
    if(mouse_over_element) {
     if (!mouse_over_element.descendantOf(drop_down)) {
       if (event.toElement != drop_down) {
         if (event.toElement != menu) {
           hide();
         }
       }
     }
    }
  });

  drop_down.observe('click', function(event) {
    hide();
  });
  
  function hide() {
    drop_down.fade({ duration: 0.3});
    drop_down.stopObserving();
  };
};

is_mac = function() {
  if (navigator) {
    if (navigator.platform) {
      return (navigator.platform.indexOf("Mac") > -1);
    }
  }
  return false;
}


show_alert = function(elem, force) {
  if (force || (!readCookie(elem.identify()))) {
    Effect.toggle(elem, 'blind', {});
    new Effect.Opacity('wrapper', { from: 1.0, to: 0.25, duration: 0.25 });
    elem.observe('click', function(event) {
      Effect.toggle(elem, 'blind', {});
      new Effect.Opacity('wrapper', { from: 0.25, to: 1.0, duration: 0.25 });
      elem.stopObserving();
    });
  };
};

show_mac_alert = function(elem, force) {
  if (is_mac()) {
    show_alart(elem,force);
  }
}



