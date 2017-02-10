// Automatically adds CSRF token to all Ajax calls.
// AUTH_TOKEN is provided by the page page (e.g. application.html.haml).

jQuery(function() {
  var authToken = jQuery('meta[name="csrf-token"]').attr('content');
  jQuery.ajaxSetup({data: {authenticity_token: authToken}});
});
