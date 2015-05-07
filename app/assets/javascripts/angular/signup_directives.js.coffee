#
# A module to contain some of our own angular directives useful for signup.
#
angular.module('ccSignupDirectives', [])

  ##
  ## Some async remote directives to help with
  ## Form validations. Use like <input username-avail="true"> &etc.
  ##
  .directive('goodClassword', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.goodClassword = (class_word) ->
          return $http.get("#{Portal.API_V1.CLASSWORD}?class_word=#{class_word}");
  ])
  .directive('usernameAvail', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.usernameAvail = (username) ->
          return $http.get("#{Portal.API_V1.LOGINS}?username=#{username}");
  ])
  .directive('emailAvail', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.emailAvail = (email) ->
          return $http.get("#{Portal.API_V1.EMAILS}?email=#{email}");
  ])

  # ng-required wasn't working the way I woudl have liked
  # this validating directive requires the field be non-blank.
  #   <input 'non-blank' => "regController.email", … >… </input>
  .directive('nonBlank', [() ->
    require: 'ngModel'
    restrict: 'A'
    link: (scope, element, attrs, ctrl) ->
      ctrl.$validators.nonBlank = (value) ->
        if value
          if value.trim
            return !!(value && value.trim().length > 0) # strings
          return true # numbers, other things...
        return false
  ])


  # Directive to compare two fields, and assert that they
  # should match... Use like:
  #   <input 'match' => "regController.password", … >… </input>
  .directive 'match', () ->
    require: 'ngModel'
    restrict: 'A'
    scope:
      match: '='
    link: (scope, elem, attrs, ctrl) ->
      scope.$watch 'match', (pass) ->
        ctrl.$validate()
        ctrl.$validators.match = (valueToValidate) ->
          return (ctrl.$pristine && (angular.isUndefined(valueToValidate) || valueToValidate == "")) || valueToValidate == scope.match



  #
  # A service to report analytics data
  # With 'gaVirtualPageView'  (not widely used)
  #
  .service('gaPageView', ['$window','$log', ($window, $log) ->
    ga_service =
      push: (page_info) ->
        # TODO start using new analytics package?
        $window._gaq.push(['_trackPageview', page_info])
        $log.log('_trackPageview' + page_info)
    return ga_service
  ])

  #
  # A service to keep track of server errors assisting
  # With 'serverErrors'  (not widely used)
  #
  .service 'errorList', () ->
    errors = {}  # field -> message
    service =
      list: errors

      addError: (field, value, message) ->
        errors[field] ?= {}
        errors[field].last_val = value
        errors[field].messages ?= []
        if errors[field].messages.indexOf(message) == -1
          errors[field].messages.push message

      isValid: (field, value) ->
        error = errors[field]
        return true unless error
        if (value == error.last_val)
          return false     # mark the form dirty until it chages.
        return true

    return service

  # Directive that compares the input to a list on the controller
  # Could be used to report on server validation errors, but isnt'
  # Use like:
  #   <input 'server-errors' => "regController.email", … >… </input>
  .directive('serverErrors', ['errorList', (errorList) ->
    require: 'ngModel'
    restrict: 'A'
    link: (scope, element, attrs, ctrl) ->
      # when the errorList changes, change the validator
      scope.$watch () ->
        JSON.stringify(errorList.list[ctrl.$name]) # changes in json rep trigger
      , () ->
        ctrl.$validators.serverErrors = (value) ->
          errorList.isValid(ctrl.$name, ctrl.$viewValue)
        ctrl.$validate()
  ])

  # Directive that compares the input to a list on the controller
  # Could be used to report on server validation errors, but isnt'
  # Use like:
  #   <server-error-essage field='email'/> (not widely used)
  .directive('serverErrorMessage', ['errorList', (errorList) ->
    restrict: 'E'
    link: (scope, element, attrs, ctrl) ->
      # when the errorList changes, update the messages
      scope.$watch () ->
        JSON.stringify(errorList.list[attrs.field]) # changes in json rep trigger
      , () ->
        scope.messages = []
        if errorList.list[attrs.field] && errorList.list[attrs.field].messages.length > 0
          scope.messages = errorList.list[attrs.field].messages
    template: """
      <div class='server-errors' ng-repeat='message in messages'>
        <span ng-bind='message' />
      </div>
      """
  ])

  # Directive that sets the intial value of a model
  # Use like:
  #   <initial-value ng-model='email' value="foo@brar.com />
  #
  .directive('initialValue', [() ->
    restrict: 'E'
    scope:
      ngModel: '='
    link: (scope, element, attrs, ctrl) ->
      scope.ngModel = attrs['value']
    template: ""
  ])

