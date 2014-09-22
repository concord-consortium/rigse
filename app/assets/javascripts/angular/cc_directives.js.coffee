
#
# A module to contain some of our own angular directives.
#
angular.module('ccDirectives', [])

  # Custom directive to compare two fields, and assert that they
  # should match... Use like:
  #   < input 'match' => "regController.password", … >… </input>
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
  # A service to keep track of server errors assisting
  # With 'serverErros'
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


  .directive('goodClassword', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.goodClassword = (class_word) ->
          return $http.get("#{API_V1.CLASSWORD}?class_word=#{class_word}");
  ])

  .directive('usernameAvail', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.usernameAvail = (username) ->
          return $http.get("#{API_V1.LOGINS}?username=#{username}");
  ])

  .directive('emailAvail', ['$http', ($http) ->
      require: 'ngModel',
      link: ($scope, element, attrs, ngModel) ->
        ngModel.$asyncValidators.emailAvail = (email) ->
          return $http.get("#{API_V1.EMAILS}?email=#{email}");
  ])


  .directive('nonBlank', [() ->
    require: 'ngModel'
    restrict: 'A'
    link: (scope, element, attrs, ctrl) ->
      ctrl.$validators.nonBlank = (value) ->
        return !!(value && value.trim().length > 0)
  ])

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
  