// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var dropdown_for = function(menu_dom_id,drop_down_dom_id) {
    var menu = $(menu_dom_id);
    var drop_down = $(drop_down_dom_id);
    var menu_width = menu.getDimensions().width
    var drop_down_width = drop_down.getDimensions().width
    if (drop_down_width < menu_width) {
      drop_down.setStyle({
        width: menu_width+"px"
      }); 
      drop_down_width = menu_width;
    }
    // var left_offset = (drop_down_width - menu_width) / -2
    var left_offset = 0;
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

// see accordian.js
// or http://www.stickmanlabs.com/accordion/
// for an MIT license accordian nav bar...  
var accordian_options = {
  // The speed of the accordion
  resizeSpeed : 8,
  // The classnames to look for
  classNames : {
  	// The standard class for the title bar
      toggle : 'accordion_toggle',
      // The class used for the active state of the title bar
      toggleActive : 'accordion_toggle_active',
      // The class used to find the content
      content : 'accordion_content'
  },
  // If you don't want the accordion to stretch to fit 
  // its content, set a value here, handy for horixontal examples.
  defaultSize : {
      height : null,
      width : null
  },
  // The direction of the accordion
  direction : 'vertical',
  // Should the accordion activate on click or say on mouseover? (apple.com)
  // onEvent : 'mouseover'
  onEvent : 'click'
}

document.observe('dom:loaded',function() {
  new Accordion('accordion_nav',accordian_options);
  
});

