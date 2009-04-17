// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var dropdown_for = function(menu_dom_id,drop_down_dom_id) {
    var menu = $(menu_dom_id);
    var drop_down = $(drop_down_dom_id);
    var menu_width = menu.getDimensions().width
    var drop_down_width = drop_down.getDimensions().width
    var left_offset = (drop_down_width - menu_width) / -2
    var top_offset = menu.getDimensions().height
    var options = { setWidth: false, setHeight: false, offsetLeft:left_offset, offsetTop: top_offset};

    drop_down.clonePosition(menu,options);
    
    menu.observe('mouseout',function(event) {
      var mouse_over_element = event.relatedTarget;
      if(mouse_over_element != drop_down) {
        hide()
      }
    });
    
    drop_down.observe('mouseout', function(event) {
      var mouse_over_element = event.relatedTarget;
      if(!mouse_over_element.descendantOf(drop_down) || event.toElement == menu) {
        hide()
      }
    });
  
    drop_down.observe('click', function(event) {
       drop_down.setStyle({left: "-1000px"});
       drop_down.stopObserving();
    });
    
    function hide() {
      drop_down.setStyle({left: "-1000px"});
      drop_down.stopObserving();
    }
  }