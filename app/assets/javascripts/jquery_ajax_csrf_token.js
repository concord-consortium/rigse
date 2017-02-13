// Automatically adds CSRF token to all Ajax calls.
// AUTH_TOKEN is provided by the page page (e.g. application.html.haml).
// It's also possible to set token in POST data (`authenticity_token`) but it can
// break some features (e.g. search which is comparing query string of the request and response).

jQuery(function() {
  var authToken = jQuery('meta[name="csrf-token"]').attr('content');
  jQuery.ajaxSetup({headers: {'X-CSRF-Token': authToken}});
});
