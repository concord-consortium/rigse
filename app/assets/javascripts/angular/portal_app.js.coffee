angular.module('cc-portal', ['ccCollaboration']).
  config ["$httpProvider", ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content')
  ]
