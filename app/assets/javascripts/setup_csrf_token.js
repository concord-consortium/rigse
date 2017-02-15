jQuery(function() {
  var authToken = jQuery('meta[name="csrf-token"]').attr('content');
  // Automatically adds CSRF token to all jQuery.ajax calls.
  // It's also possible to set token in POST data (`authenticity_token`) but it can
  // break some features (e.g. search which is comparing query string of the request and response).
  jQuery.ajaxSetup({headers: {'X-CSRF-Token': authToken}});
  // Double check if all the forms have authenticity token. Most of them should, since Rails helpers will add it.
  // But e.g. custom home or project pages defined using raw HTML probably won't have it.
  jQuery('form[method="post"]').each(function() {
    var $form = jQuery(this);
    if ($form.find('input[name="authenticity_token"]').length === 0) {
      $form.prepend('<input type="hidden" name="authenticity_token" value="' + authToken + '"/>');
    }
  });
});
