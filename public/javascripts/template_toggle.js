/*globals $ $$ Event document window */
(function() {
  var edit_class = '.template_edit_button';
  var save_class = '.template_save_button';
  var disable_class = '.template_disable_button';
  var enable_class = '.template_enable_button';
  var template_container_class = '.template_container';
  var edit_container_class = '.template_edit_container';
  var view_container_class = '.template_view_container';
  var title_container_class = '.template_view_title';
  
  var disable_button = function(button) {
    button.removeClassName('enabled');
    button.addClassName('disabled');
  };

  var enable_button = function(button) {
    button.removeClassName('disabled');
    button.addClassName('enabled');
  };

  var enable_section = function(evt) {
    var enabler = evt.element();
    var container = enabler.up(template_container_class);
    var _edit_button = container.down(edit_class);
    var _save_button = container.down(save_class);
    var disabler = container.down(disable_class);
    var title = container.down(title_container_class);
    _edit_button.show();
    enable_button(_edit_button);
    _save_button.show();
    disable_button(_save_button);
    container.down(view_container_class).show();
    container.removeClassName('disabled');
    enabler.hide();
    disabler.show();
  };

  var disable_section = function(evt) {
    var disabler = evt.element();
    var container = disabler.up(template_container_class);
    var enabler = container.down(enable_class);
    var title = container.down(title_container_class);
    container.down(edit_class).hide();
    //container.down(save_class).hide();
    container.down(view_container_class).hide();
    container.down(edit_container_class).hide();
    container.addClassName('disabled');
    disabler.hide();
    enabler.show();
  };

  var open_editor = function(evt) {
    var edit_button = evt.element();
    var container = edit_button.up(template_container_class);
    var save_button = container.down(save_class);
    var edit_container = container.down(edit_container_class);
    var view_container = container.down(view_container_class);
    enable_button(save_button);
    disable_button(edit_button);
    edit_container.show();
    view_container.hide();
  };

  var close_editor = function(evt) {
    var save_button = evt.element();
    var container = save_button.up(template_container_class);
    var edit_button = container.down(edit_class);
    var edit_container = container.down(edit_container_class);
    var view_container = container.down(view_container_class);
    enable_button(edit_button);
    disable_button(save_button);
    edit_container.hide();
    view_container.show();
  };

  document.observe('dom:loaded', function() {
    $$(save_class).each(function(element){
        element.observe('click', close_editor);
        disable_button(element);
    });
    $$(edit_container_class).each(function(element){
      element.hide();
    });


    $$(edit_class).each(function(element){
        element.observe('click', open_editor);
        enable_button(element);
    });
    $$(enable_class).each(function(elm) {
      elm.observe('click', enable_section);
      elm.hide();
    });
    $$(disable_class).each(function(elm) {
      elm.observe('click', disable_section);
    });

    // initial visibility of buttons:
    $$(template_container_class).each(function(elm) {
      elm.observe('mouseover', function(evt) {
        if (elm.hasClassName('over')) {
          return;
        }
        $$(template_container_class).each(function(selected){
          selected.removeClassName('over');
          selected.down('.buttons').hide();
        });
        elm.addClassName('over');
        elm.down('.buttons').show();
      });
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

  });

}());
