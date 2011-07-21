var selected_class = 'item_selected';
var unselected_class = 'item_selectable';
var rites_document = {};
var last_rites_document = {}

var is_selected = function(element) { return element.hasClassName(selected_class)}
var selected = function(toggle_element)         { return (readCookie(id_for_toggle(toggle_element)) == "true");    }
var set_cookie = function(toggle_element)         { createCookie(id_for_toggle(toggle_element),'true'); }
var remove_cookie = function(toggle_element)      { eraseCookie(id_for_toggle(toggle_element)); }

var get_selectable = function(element) { 
  element = $(element)
  if (element.hasClassName(unselected_class)) return element;
  if (element.hasClassName(selected_class)) return element;
  if (element.up("." + unselected_class)) return element.up("." + unselected_class);
  if (element.up("." + selected_class)) return element.up("." + selected_class)
  return null
}

var item_select = function(event) {
  // deselect everyone first:
  item_deselect();

  var element = event.element();
  var element = $(element); // extend
  var selected = get_selectable(element)

  if (selected) {
    var type = '';
    var id = '';
    
    selected.identify().gsub(/item_([\w|_]+)_(\d+)/, function(match){
      type = match[1];
      id = match[2];
    });
    selected.addClassName(selected_class);
    selected.removeClassName(unselected_class);
    // add/remove class for parent LI too if one exists
	if (selected.up('li')) {
		selected.up('li').addClassName(selected_class);
		selected.up('li').removeClassName(unselected_class);
	}
	// make sure child element's class changes too if LI itself is selected
	if (selected.down('.item')) {
		selected.down('.item').addClassName(selected_class);
		selected.down('.item').removeClassName(unselected_class);
	}
    rites_document.selected_type=type;
    rites_document.selected_id=id;
    if (rites_document.selected_type != last_rites_document.selected_type || 
        rites_document.selected_id != last_rites_document.selected_id) {
          update_links();
          last_rites_document.selected_id = rites_document.selected_id;
          last_rites_document.selected_type = rites_document.selected_type;
    }
  }
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
    // add/remove class for parent LI too if one exists
	if (element.up('li')) {
		element.up('li').removeClassName(selected_class);
		element.up('li').addClassName(unselected_class);
	}
	// make sure child element's class changes too if LI itself is selected
	if (element.down('.item')) {
		element.down('.item').addClassName(selected_class);
		element.down('.item').removeClassName(unselected_class);
	}
    rites_document.selected_type=null;
    rites_document.selected_id=null;
    rites_document.selected_name="unknown"
  });
}

var update_links = function() {
  if(rites_document && $('copy_link')) {
    if(rites_document.selected_type !=null) {
      var template = new Template('<a href="#" class="rollover"><img src="/images/paste-in.png"></a><a href="#">copy #{name}</a>');
      // var template = new Template('<a>copy #{type}:#{id}</a>');
      $('copy_link').addClassName('copy_paste_enabled');
      $('copy_link').removeClassName('copy_paste_disabled');
      $('copy_link').observe('click',copy);
      new Ajax.Request('/name_for_clipboard_data?clipboard_data_type='+rites_document.selected_type+'&clipboard_data_id='+rites_document.selected_id, {
        method: 'get',
        onSuccess: function(transport) {
          rites_document.selected_name = transport.responseText
          $('copy_link').update(template.evaluate({type:rites_document.selected_type, name:rites_document.selected_name}));
        }
      });
          
    }
    else {
      $('copy_link').addClassName('copy_paste_disabled');
      $('copy_link').removeClassName('copy_paste_enabled');      
      $('copy_link').stopObserving();  
      $('copy_link').update('copy (nothing selected)');
    }
  }
}

var copy = function() {
  var template = new Template('#{type}:#{name} is now in your clipboard.');
  createCookie('clipboard_data_type',rites_document.selected_type); 
  createCookie('clipboard_data_id',rites_document.selected_id);
  alert(template.evaluate({type:rites_document.selected_type, name:rites_document.selected_name}));
  // replace the paste button, much harder?
  var params = {
    container_id: container_id,
    clipboard_data_type: rites_document.selected_type, 
    clipboard_data_id:rites_document.selected_id
  };
  if (auth_token() ) {
    params.authenticity_token = auth_token();
  }
  new Ajax.Updater({ 
      // onCreate: 'show_wait()',
      // onComplete: 'hide_wait()',
      success: 'paste_link' 
    }, 'paste_link', { parameters: params });
}

var show_wait = function () {
  if($('waiter')) {
    $('waiter').show();
  }
}

var hide_wait = function () {
  if($('waiter')) {
    $('waiter').hide();
  }
}

document.observe('click',item_select);