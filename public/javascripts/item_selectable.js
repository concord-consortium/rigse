var selected_class = 'item_selected';
var unselected_class = 'item_selectable';
var rites_document;

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

  element = event.element();
  element = $(element); // extend
  selected = get_selectable(element)

  if (selected) {
    var type = '';
    var id = '';
    
    selected.identify().gsub(/item_([\w|_]+)_(\d+)/, function(match){
      type = match[1];
      id = match[2];
    });
    selected.addClassName(selected_class);
    selected.removeClassName(unselected_class);
    rites_document.selected_type=type;
    rites_document.selected_id=id;
  }
  update_links();
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
    rites_document.selected_type=null;
    rites_document.selected_id=null;
  });
}

var update_links = function() {
  if(rites_document.selected_type !=null) {
    var template = new Template('<a>copy #{type}:#{id}</a>');
    $('copy_link').addClassName('copy_enabled');
    $('copy_link').observe('click',copy);
    $('copy_link').update(template.evaluate({type:rites_document.selected_type, id:rites_document.selected_id}));    
  }
  else {
    $('copy_link').addClassName('copy_disabled');
    $('copy_link').stopObserving();  
    $('copy_link').update('copy (nothing selected)');
  }
}

var copy = function() {
  var template = new Template('#{type}:#{id} is now in your clipboard.');
  createCookie('clipboard_data_type',rites_document.selected_type); 
  createCookie('clipboard_data_id',rites_document.selected_id);
  alert(template.evaluate({type:rites_document.selected_type, id:rites_document.selected_id}));
  // replace the paste button, much harder?
  new Ajax.Updater({ 
      // onCreate: 'show_wait()',
      // onComplete: 'hide_wait()',
      success: 'paste_link' 
    }, 
    'paste_link', {
      parameters: { 
        authenticity_token:AUTH_TOKEN,
        container_id: container_id,
        clipboard_data_type: rites_document.selected_type, 
        clipboard_data_id:rites_document.selected_id
      }
  });
}

var show_wait = function () {
  $('waiter').show();
}

var hide_wait = function () {
  $('waiter').hide();
}

document.observe('click',item_select);