var selected_class = 'item_selected';
var unselected_class = 'item_selectable';
var get_selectable = function(element) { return (element.hasClassName(unselected_class) || element.hasClassName(selected_class) || element.up("." + unselected_class)) || element.up("." + selected_class)}
var is_selected = function(element) { return element.hasClassName(selected_class)}

var item_select = function(event) {
  element = event.element();
  element = $(element); // extend
  selected = get_selectable(element)
  // deselect everyone first:
  item_deselect();
  
  if (selected) {
    if (selected.hasClassName(selected_class)) {
      var type = '';
      var id = '';
    
      selected.identify().gsub(/item_([\w|_]+)_(\d+)/, function(match){
        type = match[1];
        id = match[2];
      });
      var edit_dom_id = "form_"   +type+ "_" +id;
      var show_dom_id = "display_"+type+ "_" +id;
    }
    else {
      selected.addClassName(selected_class);
      selected.removeClassName(unselected_class);
    }
  }
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
  });
}

document.observe('click',item_select);