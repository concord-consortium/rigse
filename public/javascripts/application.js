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

// show/hide project sign in form labels on field blur/focus
document.observe("dom:loaded", function() {
	if ($("project-signin")) {
		// username field listeners
		Event.observe('login', 'focus', function(event) {
			$("login").previous(0).setStyle({"display": "none"});
		});
		Event.observe('login', 'blur', function(event) {
			if ($("login").value == "") $("login").previous(0).setStyle({"display": "block"});
		});
		// password field listeners
		Event.observe('password', 'focus', function(event) {
			$("password").previous(0).setStyle({"display": "none"});
		});
		Event.observe('password', 'blur', function(event) {
			if ($("password").value == "") $("password").previous(0).setStyle({"display": "block"});
		});
		// check for username value on page load
		if ($("login").value != '') {
			$("login").previous(0).setStyle({"display": "none"});
		}
	}
});