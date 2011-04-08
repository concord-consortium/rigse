// some docuimentation might be created for natural docs
// http://naturaldocs.org/documenting/walkthrough.html#MoreFormatting

/*globals clonePosition, descendantOf, duration, fade, getDimensions, 
    height, hide, log, observe, offsetLeft, offsetTop, padding, 
    relatedTarget, setHeight, setStyle, setWidth, show, width, "z-index"
*/
var dropdown_for = function(dropDownLinkId,dropDownMenuId) {
  var dropDownLink = $(dropDownLinkId);
  var dropDownMenu = $(dropDownMenuId);
  var dropDownLink_width = dropDownLink.getDimensions().width;
  var dropDownMenu_width = dropDownMenu.getDimensions().width;
  var padding = 0;
  dropDownMenu.show();
  dropDownMenu.hide();
  dropDownMenu.setStyle({'z-index': 2000});
  dropDownMenu.setStyle({'padding' : padding + "px"});
  
  if (dropDownMenu_width < dropDownLink_width) {
    dropDownMenu.setStyle({
      width: dropDownLink_width+"px"
    }); 
    dropDownMenu_width = dropDownLink_width;
  }
  
  var left_offset = dropDownLink_width/-1;
  var top_offset = dropDownLink.getDimensions().height - padding;
  var options = { setWidth: false, setHeight: false, offsetLeft: left_offset, offsetTop: top_offset};

  var is_showing = false;
  var in_dropDownLink = false;
  var in_dropDownMenu = false;
  var hide_timer = null;

  dropDownMenu.clonePosition(dropDownLink,options);
  
  var hide = function() {
    dropDownMenu.hide();
    is_showing = false;
    hide_timer = null;
  };

  var show =  function() {
    dropDownMenu.show();
    is_showing = true;
    if (hide_timer !== null) {
      clearTimeout(hide_timer);
      hide_timer = null;
    }
  };
  
  /**
  * 
  **/
  var updateMouseStatus = function() {
    if (in_dropDownLink || in_dropDownMenu) {
      show();
    }
    else {
      if (is_showing) {
        is_showing = false;
        hide_timer = setTimeout(hide,100);        
      }
      else {
      }
    }
  };
  
  var mouseEnterHandler = function(event) {
    var mouse_over_element = event.target;
    if(mouse_over_element) {
     if (mouse_over_element == dropDownMenu || mouse_over_element.descendantOf(dropDownMenu)) {
        in_dropDownMenu = true;
     }
     else {
        in_dropDownMenu = false;
     }
     if (mouse_over_element == dropDownLink || mouse_over_element.descendantOf(dropDownLink)) {
       in_dropDownLink = true;
     }
     else {
       in_dropDownLink = false;
     }
    }
    updateMouseStatus();
  };
  

  document.observe('mouseover', mouseEnterHandler);
  dropDownMenu.observe('click', function(event) {
    show();
  });
  
};
