
// Workaround for prototype-ui and contentflow js conflict

// We are redifining the function in conflict instead of modifying the prototype-ui library.
UI.Window.prototype.setResizable = function(resizable) {
  this.options.resizable = resizable;
  var toggleClassName = (resizable ? 'add' : 'remove') + 'ClassName';
  this.element[toggleClassName]('resizable');
  this.element.select('div:[class*=_sizer]').invoke(resizable ? 'show' : 'hide');
  if (resizable) {
    this.createResizeHandles();
  }
  this.element.select('div.se').first()[toggleClassName]('se_resize_handle');
  return this;
};
