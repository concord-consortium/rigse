angular.module("registrationApp", ["ccDirectives",'ui.select' ])
  .controller "RegistrationController", [ '$http', ($http) ->
    console.log("we have registered our controller")
    self = @
    self.$http = $http

    self.$http({method: 'GET', url: API_V1.COUNTRIES})
      .success (data, status, headers, config) ->
        self.countries = data

      .error (data, status) ->
          console.log "error"
          self.countries || =[]

    self.isStudent = () ->
      self.registrationType == "student";

    self.isTeacher = () ->
      self.registrationType == "teacher";

    self.readyToRegister = () ->
      return self.first_name && self.last_name && self.confirmPassword && self.registrationType

    self.startRegistration = () ->
      self.didStartRegistration = true

    self.showTeacherPage = () ->
      return self.didStartRegistration && self.registrationType == "teacher"

    self.showStudentPage = () ->
      return self.didStartRegistration && self.registrationType == "student"

    self.showPage1 = () ->
      !self.didStartRegistration

    self.showState = () ->
      self.country == "USA"

    self.showDistrict = () ->
      self.showState() && self.state

    self.showSchool = () ->
      (self.showDistrict() && self.district) || (self.country != 'USA' && self.country)
  ]

angular.module('ccDirectives', [])
  .directive 'match', () ->
    require: 'ngModel'
    restrict: 'A'
    scope: 
      match: '='
    link: (scope, elem, attrs, ctrl) ->
      scope.$watch 'match', (pass) ->
        ctrl.$validate()
        ctrl.$validators.match = (modelValue) ->
          return (ctrl.$pristine && (angular.isUndefined(modelValue) || modelValue == "")) || modelValue == scope.match
  .directive 'foo', () ->
    require: 'ngModel'
    restrict: 'A'
    scope: 
      foo: '='
    link: (scope, elem, attrs, ctrl) ->
      scope.$watch 'match', (pass) ->
        ctrl.$validate()
        ctrl.$validators.match = (modelValue) ->
          return (ctrl.$pristine && (angular.isUndefined(modelValue) || modelValue == "")) || modelValue == scope.foo