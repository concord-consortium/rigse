(function() {
  Event.observe(window, 'load', function() {
    window.show_section = function(element, button) {
      $$('.unit-navigation').each(function(elem) { elem.removeClassName('selected-category'); } );
      $$('.show_section').each(function(elem)    { elem.hide();                               } );
      if (typeof element !== 'undefined') {
        $(element).show();
      }
      if (typeof button !== 'undefined') {
        $(button).addClassName('selected-category');
      }
    };

    // TODO: Not currently used anywhere.
    //var toggle_info_block = function(link, element_id) {
      //var offset = $(link).offset();
      //var element = $(element_id);
      //var info_block_top = offset.top + 'px';
      //var info_block_left = offset.left + 'px';
      //if (element.getStyle('display') == 'block') {
        //new Effect.Fade(element, { duration:1});
      //} else {
        //element.setStyle({
                //'position': 'absolute',
                //'left': '0',
                //'top': '10px',
                //'width': '250px',
                //'z-index': 1000000,
                //'box-shadow': '3px 3px 10px #555',
                //'-moz-box-shadow': '3px 3px 10px #555',
                //'-webkit-box-shadow': '3px 3px 10px #555'
                //});
        //new Effect.Appear(element, {duration:1, from:1.0, to:1.0});
      //}
    //};

    var updateCounter = function(delta,dom_id) {
      var counter, text, value = null;
      counter = $$(dom_id);
      counter.each(
        function(elm) {
          text  = elm.innerText;
          if (text) {
            value = parseInt(text,10);
            value = value + delta;
            elm.update(value);
          }
        }
      );
    };

    var updateOfferingCounter = function(delta) {
      updateCounter(delta,'#total-selected');
      updateCounter(delta,'.selected-category > .tag_count');
    };

    $(document).updateOfferings = function(input, portal_clazz_id, activity_id, offering_id, runnable_type,section_id) {
      // TODO: remove console logging statements
      var ajaxUpdater;
      var new_checked_state = input.checked;
      if(new_checked_state){
        // User wants to make a new offering
        ajaxUpdater = new Ajax.Request('/portal/classes/' + portal_clazz_id + '/add_offering',
          {
            parameters: {
              id: portal_clazz_id,
              runnable_id: activity_id,
              runnable_type: runnable_type
            },
            asynchronous:true, evalScripts:true,
            onCreate: function() {
              updateOfferingCounter(+1);
              $('total-selected').setStyle({opacity: 0.5});
            },
            onFailure: function(transport) {
              updateOfferingCounter(-1);
              $('total-selected').setStyle({opacity: 1});
            },
            onSuccess: function(transport) {
              $('total-selected').setStyle({opacity: 1});

              // Find all input elements for the same activity and update them all
              $$('input[name="'+input.name+'"]').each(function(inputElement) {
                if(inputElement.value == input.value){
                  inputElement.writeAttribute("checked", true);
                  inputElement.writeAttribute("onclick", "updateOfferings(this, "+portal_clazz_id+", "+activity_id+", "+transport.responseText+", '"+runnable_type+"')");
                }
              });
              // TODO: flash a success message from here
            }
            // TODO: on failure find all input elements for the same activity and update them all (uncheck them)
            // TODO: flash a failure message from here
           }
        );
      } else{
        // User wants to remove an offering
        ajaxUpdater = new Ajax.Updater('flash',
          '/portal/classes/' + portal_clazz_id + '/remove_offering',
          {
            parameters: {
              id: portal_clazz_id,
              runnable_id: activity_id,
              offering_id: offering_id,
              runnable_type: runnable_type
            },
            asynchronous:true, evalScripts:true,
            onCreate: function() {
              updateOfferingCounter(-1);
              $('total-selected').setStyle({opacity: 0.5});
            },
            onFailure: function(transport) {
              updateOfferingCounter(+1);
              $('total-selected').setStyle({opacity: 1});
            },
            onSuccess: function(transport) {
              $('total-selected').setStyle({opacity: 1});

              // TODO: find all input elements for the same activity and update them all (uncheck them and set offering id to -1)
              $$('input[name="'+input.name+'"]').each(function(inputElement) {
                if(inputElement.value == input.value){
                  inputElement.writeAttribute("checked", null);
                  inputElement.writeAttribute("onclick", "updateOfferings(this, "+portal_clazz_id+", "+activity_id+", -1, '"+runnable_type+"')");
                }
              });
            }
            // TODO: on failure find all input elements for the same activity and update them all (check them)
          }
        );
      }
      return false;
    };
    var last_panel = $$(".show_section").first();
    var last_button = $$('.bin_button').first();
    if (last_panel && last_button) {
      show_section(last_panel,last_button);
    }
  });
})();
