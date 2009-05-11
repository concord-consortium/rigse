var selected_class = 'selected';
var unselected_class = 'selectable';
var get_selectable = function(element) { return (element.hasClassName(unselected_class) || element.hasClassName(selected_class) || element.up("." + unselected_class)) || element.up("." + selected_class)}
var is_selected = function(element) { return element.hasClassName(selected_class)}

var item_select = function(event) {
  element = event.element()
  selected = get_selectable(element)
  if (selected) {
    console.log("clicked");
    if (selected.hasClassName(selected_class)) {
      var type = '';
      var id = '';
    
      selected.identify().gsub(/item_([\w|_]+)_(\d+)/, function(match){
        type = match[1];
        id = match[2];
      });
      console.log('edit-click on class='+type+' id='+id);
      var edit_dom_id = "form_"   +type+ "_" +id;
      var show_dom_id = "display_"+type+ "_" +id;
      console.log(edit_dom_id);
      $(edit_dom_id).show();
      $(show_dom_id).hide();
    }
    else {
      item_deselect();
      selected.addClassName(selected_class);
      selected.removeClassName(unselected_class);
      // selected.down('.action_menu').show();
    }
  }
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
    // element.down('.action_menu').hide();
  });
}

document.observe('click',item_select);