var selected_class = 'item_selected';
var unselected_class = 'item_selectable';

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
  console.log(selected)
  if (selected) {
    var type = '';
    var id = '';
    
    selected.identify().gsub(/item_([\w|_]+)_(\d+)/, function(match){
      type = match[1];
      id = match[2];
    });
    selected.addClassName(selected_class);
    selected.removeClassName(unselected_class);
    document.selected_type=type;
    document.selected_id=id;
  }
  update_links();
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
    document.selected_type=null;
    document.selected_id=null;
  });
}

var update_links = function() {
  if(document.selected_type !=null) {
    var template = new Template('<a>copy #{type}:#{id}</a>');
    $('copy_link').addClassName('copy_enabled');
    $('copy_link').observe('click',copy);
    $('copy_link').update(template.evaluate({type:document.selected_type, id:document.selected_id}));    
  }
  else {
    $('copy_link').addClassName('copy_disabled');
    $('copy_link').stopObserving();  
    $('copy_link').update('copy (nothing selected)');
  }
}

var copy = function() {
  var template = new Template('#{type}:#{id} is now in your clipboard.');
  createCookie('clipboard_data_type',document.selected_type); 
  createCookie('clipboard_data_id',document.selected_id);
  alert(template.evaluate({type:document.selected_type, id:document.selected_id}));
  // replace the paste button, much harder?
  new Ajax.Updater({ success: 'paste_link' }, 'paste_link', {
    parameters: { 
      authenticity_token:AUTH_TOKEN,
      clipboard_data_type: document.selected_type, 
      clipboard_data_id:document.selected_id}
  });
}


document.observe('click',item_select);