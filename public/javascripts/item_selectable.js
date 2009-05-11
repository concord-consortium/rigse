var selected_class = 'selected';
var unselected_class = 'selectable';
var get_selectable = function(element) { return (element.hasClassName(unselected_class) || element.up("." + unselected_class) || false) }

var item_select = function(event) {
  item_deselect();
  element = event.element()
  console.log("clicked");
  selected = get_selectable(element)
  if (selected) {
    console.log("way clicked");
    selected.addClassName(selected_class);
    selected.removeClassName(unselected_class);
  }
}

var item_deselect = function() {
  $$("." + selected_class).each(function(element){
    element.removeClassName(selected_class);
    element.addClassName(unselected_class);
  });
}

document.observe('click',item_select);