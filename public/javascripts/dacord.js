
var toggle = function(e) {
  var element = $(e.element())
  var tohide = $(element).next('ul');
  Effect.toggle(tohide,'blind',{ duration: 0.4 });
  if (element.hasClassName('accordion_toggle_active')) {
    Cookie.removeData(element.identify())
    element.removeClassName('accordion_toggle_active')
    element.addClassName('accordion_toggle')
  }
  else {
    Cookie.setData(element.identify(),true)
    element.removeClassName('accordion_toggle')
    element.addClassName('accordion_toggle_active')
  }
  Cookie.store()
}

document.observe('dom:loaded', function() {
  $$('.accordion_toggle').each(function(i){
    i.observe('click',toggle)
  });
})
