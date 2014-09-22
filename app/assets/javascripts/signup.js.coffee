angular.module("registrationApp", ["ccDirectives",'ui.select','ui.validate', "ngMessages"])
  .controller "RegistrationController", [ '$scope', '$http', '$log', 'errorList',  ($scope, $http, $log, errorList) ->
    self = @
    self.questions = []          # these are the ones the student has chosen
    self.security_questions = [] # these are given to us from the server
    self.serverErrors = errorList.list
    
    self.addError = () ->
      errorList.addError('first_name',self.last_name,'message')

    self.loadCountries = () ->
      self.loadRemoteCollection('countries')

    self.loadStates = () ->
      self.loadRemoteCollection('states')

    self.loadSecurityQuestions = () ->
      self.loadRemoteCollection('security_questions')

    self.loadDisrticts = () ->
      params = { state: self.state }
      self.loadRemoteCollection('districts',params)

    self.loadDomesticSChools = () ->
      params = { district_id : self.district.id }
      self.loadRemoteCollection('schools',params)

    self.loadIntlSchools = () ->
      params = { country_id : self.country.id }
      self.loadRemoteCollection('schools',params)

    self.countrySelected = () ->
      if self.isDomestic()
        self.loadStates()
      else
        self.loadIntlSchools()

    self.stateSelected = () ->
      if self.isDomestic()
        self.loadDisrticts()

    self.districtSelected = () ->
      if self.isDomestic()
        self.loadDomesticSChools()

    self.loadRemoteCollection = (collectionName, params={}) ->
      url = API_V1[collectionName.toUpperCase()]
      $http({method: 'GET', url: url, params: params})
      .success (data, status, headers, config) ->
        $log.log("loaded #{collectionName} collection from #{url}")
        self[collectionName] = data

      .error (data, status) ->
        $log.log "Error loading #{collectionName} collection"
        self[collectionName] || =[]

    self.postToResource = (resourceName, data={}, successCall, failCall) ->
      url = API_V1[resourceName.toUpperCase()]
      $http({method: 'POST', url: url, data: data})
      .success (data, status, headers, config) ->
        $log.log("added #{resourceName} to #{url}")
        self[resourceName] = data
        successCall(data) if successCall
      .error (data, status) ->
        $log.log "Error posting #{resourceName} collection"
        errrorfields = data.message
        self.errors = []
        for item of errrorfields
          $log.log("Error in #{item}")
          errorList.addError(item, self[item], errrorfields[item])
        failCall(data) if failCall

    self.uniqueQuestions = (value) ->
      return true unless value && value.length > 0
      self.questions.indexOf(value) == -1 ? true : false

    self.readyToRegister = () ->
      (self.first_name && self.last_name && self.password_confirmation && self.registrationType)

    self.sendRegistration = () ->
      resource = "#{self.registrationType}s"
      self.postToResource resource, self.form_params(), (data) ->
        self.did_finish = true
        # copy data into this controller
        for field of data
          self[field] = data[field]

    self.form_params = () ->
      return {
        'first_name': self.first_name
        'last_name':  self.last_name
        'password':   self.password
        'password_confirmation': self.password_confirmation
        'email': self.email
        'login': self.login
        'class_word': self.class_word
        'answers': self.answers
        'questions': self.questions
      }

    self.startRegistration = () ->
      self.didStartRegistration = true
      self.loadCountries() if self.registrationType == "teacher"
      self.loadSecurityQuestions() if self.registrationType == "student"

    self.nowShowing = () ->
      return "page1" unless self.didStartRegistration
      return "success" if self.did_finish
      return self.registrationType

    self.isDomestic = () ->
      return false unless self.country
      self.country.id == API_V1.USA_ID
    
    self.showState = () ->
      self.isDomestic()

    self.showDistrict = () ->
      self.showState() && self.state

    self.showSchool = () ->
      return false unless self.country
      (self.showDistrict() && self.district) || (! self.isDomestic())
  ]

       
#
# A module to contain some of our own hand-made directives.
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
  