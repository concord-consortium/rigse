/*globals $ $$ Event document window */
(function() {
  var edit_class = '.template_edit_link';
  var cancel_class = '.template_cancel_link';
  var wait_class = ".template_wait";
  var save_class = '.template_save_button';
  var disable_button_class = '.template_disable_button';
  var enable_button_class = '.template_enable_button';
  var enable_check_class = '.template_enable_check';
  var enable_element_check_class = '.element_enable_check';
  var disabled_section_class = '.disabled_section';
  var enabled_section_class = '.enabled_section';
  var template_container_class = '.template_container';
  var disabled_container_class = '.template_disabled_container';
  var edit_container_class = '.template_edit_container';
  var view_container_class = '.template_view_container';
  var title_container_class = '.template_section_title';

  var get_rails_model = function(element) {
    var id = null;
    var type = null;
    element.identify().gsub(/template_container_([\w|_]+)_(\d+)/, function(match){
      type = match[1];
      id = match[2];
    });
    return ({ type: type, id: id});
  };

  var get_model_type = function(element) {
    return get_rails_model(element).type;
  };
  var get_model_id = function(element) {
    return get_rails_model(element).id;
  };

  var disable_url = function(element) {
    return "/{type}s/{id}/disable".gsub("{id}",get_model_id(element)).gsub("{type}",get_model_type(element));
  };

  var enable_url = function(element) {
    return "/{type}s/{id}/enable".gsub("{id}",get_model_id(element)).gsub("{type}",get_model_type(element));
  };

  var server_enable = function(element) {
    var url = enable_url(element);
    new Ajax.Request(url,{ method:'POST', onFailure: disable_section});
  };
  
  var server_disable = function(element) {
    var url = disable_url(element);
    new Ajax.Request(url,{ method:'POST', onFailure: enable_section});
  };


  var disable_button = function(button) {
    button.removeClassName('enabled');
    button.addClassName('disabled');
  };

  var enable_button = function(button) {
    button.removeClassName('disabled');
    button.addClassName('enabled');
  };

  var enable_section = function(container) {
    viewContainer = container.down(view_container_class);
    viewContainer.select(template_container_class).each(function(elm){
      elm.show();
    });
    
    var _edit_button = container.down(edit_class);
    var _save_button = container.down(save_class);
    if (!!_edit_button) {
      _edit_button.show();
    }
    if (!!_save_button) {
      _save_button.show();
    }
  };
  
  var handle_enable_check_evt = function(evt) {
    var checkbox = evt.element();
    var container = checkbox.up(template_container_class);
    if (checkbox.checked) {
      enable_section(container);
      server_enable(container);
    } else {
      disable_section(container);
      server_disable(container);
    }
  };

  var disable_section = function(container) {
    viewContainer = container.down(view_container_class);
    viewContainer.select(template_container_class).each(function(elm){
      elm.hide();
    });
  };
  
  var handle_enable_element_check_evt = function(evt) {
    var checkbox = evt.element();
    var container = checkbox.up(template_container_class);
    if (checkbox.checked) {
      enable_element(container);
      server_enable(container);
    } else {
      disable_element(container);
      server_disable(container);
    }
  };
  
  var enable_element = function(container) {
    viewContainer = container.down(view_container_class);
    viewContainer.show();
    var edit_button = container.down(edit_class);
    if (!!edit_button) {
      edit_button.show();
    }
  };
  
  var disable_element = function(container) {
    close_editor(container);
    viewContainer = container.down(view_container_class);
    viewContainer.hide();
    var edit_button = container.down(edit_class);
    if (!!edit_button) {
      edit_button.hide();
    }
  };

  var handle_open_editor_evt = function(evt) {
    var edit_button = evt.element();
    var container = edit_button.up(template_container_class);
    open_editor(container);
  };
  
  var open_editor = function(container) {
    var save_button = container.down(save_class);
    var edit_button = container.down(edit_class);
    var edit_container = container.down(edit_container_class);
    var view_container = container.down(view_container_class);
    enable_button(save_button);
    edit_button.hide();
    edit_container.show();
    view_container.hide();
  };
  
  var handle_close_editor_evt = function(evt) {
    var save_button = evt.element();
    var container = save_button.up(template_container_class);
    close_editor(container);
  };

  var close_editor = function(container) {
    var edit_button = container.down(edit_class);
    var edit_container = container.down(edit_container_class);
    var view_container = container.down(view_container_class);
    edit_button.show();
    edit_container.hide();
    view_container.show();
  };


  window.template_save_loading = function(container){
    var el = $(container).up('.template_container');
    var save_button = el.down(save_class);
    var edit_button = el.down(edit_class);
    var disable_button = el.down(disable_button_class);
    var wait = el.down(wait_class);
    var edit_container = el.down(edit_container_class);
    var view_container = el.down(view_container_class);
    wait.show();
    edit_button.hide();
    disable_button.hide();
    //el.addClassName('disabled');
  };

  window.template_save_success = function(container) {
    var el = $(container).up('.template_container');
    var save_button = el.down(save_class);
    var edit_button = el.down(edit_class);
    var disable_button = el.down(disable_button_class);
    var wait = el.down(wait_class);
    var edit_container = el.down(edit_container_class);
    var view_container = el.down(view_container_class);
    wait.hide();
    edit_button.show();
    disable_button.show();
    el.removeClassName('disabled');
  };

  window.template_save_failure = function(container) {
    var el = $(container).up('.template_container');
    var save_button = el.down(save_class);
    var edit_button = el.down(edit_class);
    var wait = el.down(wait_class);
    var edit_container = el.down(edit_container_class);
    var view_container = el.down(view_container_class);
    alert('unable to save your change, please try again ...');
    wait.hide();
    edit_button.show();
    disable_button.show();
    el.removeClassName('disabled');
  };


  document.observe('dom:loaded', function() {
    $$(wait_class).each(function(element){
        element.hide();
    });

    $$(save_class).each(function(element){
        element.observe('click', handle_close_editor_evt);
        disable_button(element);
    });
    $$(cancel_class).each(function(element){
        element.observe('click', function(evt) {
        evt.stop(); // don't submit form
        handle_close_editor_evt(evt);
        });
    });
    $$(edit_container_class).each(function(element){
      element.hide();
    });


    $$(edit_class).each(function(element){
        element.observe('click', handle_open_editor_evt);
        enable_button(element);
    });
    
    $$(enable_check_class).each(function(elm) {
      elm.observe('click', handle_enable_check_evt);
    });
    
    $$(enable_element_check_class).each(function(elm) {
      elm.observe('click', handle_enable_element_check_evt);
    });

    $$('body').each(function(container) {
      container.observe('mouseover', function(evt) {
        var elm = evt.element();
        if (!elm.match(template_container_class)) {
          elm = elm.up(template_container_class);
        }
        if (typeof elm == 'undefined' || typeof elm === null) {
          return;
        }
        if (elm.hasClassName('over')) {
          return;
        }
        elm.addClassName('over');
      });
    });
    
    // enable all sections initially
    $$(template_container_class).each(function(elm) {
      if (elm.id.indexOf('section') > -1){
        enable_section(elm);
        elm.down(enable_check_class).checked = true;
      }
    });
    
    // open all empty main_content text fields
    $$("textarea").each(function(elm) {
      if (elm.id.indexOf('section') > -1 && elm.innerHTML == ""){
        var container = elm.up(template_container_class);
        open_editor(container);
      }
    });

    // then disable initially disabled section
    $$(disabled_section_class).each(function(elm) {
      if (elm.id.indexOf('section') > -1){
        disable_section(elm);
        elm.down(enable_check_class).checked = false;
      }
    });
    
    // disable initially disabled page elements
    $$(enable_element_check_class).each(function(check) {
      var container = check.up(template_container_class);
      if (container.hasClassName('disabled_section')){
        disable_element(container);
        check.checked = false;
      } else {
        check.checked = true;
      }
    });

    // cancel the double-click behavior of editable_block
    // TODO: (?) dont put the editable behavior inline? Use unobtrusive jquery?
    $$('.editable_block').each(function(element) {
      var parent = element.up(view_container_class);
      element.childElements().each(function(child) {
        parent.insert(child.remove());
      });
      element.remove();
    });

    // when all the above javascript has beeb evluated, show the elements:
    $$('.template_listing').each(function(elm) {
      elm.show();
    });
  });

}());
