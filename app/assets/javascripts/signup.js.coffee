angular.module("registrationApp", ["ccDirectives",'ui.select','ui.validate'])
  .controller "RegistrationController", [ '$scope', '$http', '$log', ($scope,$http,$log) ->
    self = @
    self.questions = []          # these are the ones the student has chosen
    self.security_questions = [] # these are given to us from the server
    self.errors = []             # server validation errors
    
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

    self.postToResource = (resourceName, data={}) ->
      url = API_V1[resourceName.toUpperCase()]
      $http({method: 'POST', url: url, data: data})
      .success (data, status, headers, config) ->
        $log.log("added #{resourceName} to #{url}")
        self[resourceName] = data

      .error (data, status) ->
        $log.log "Error posting #{resourceName} collection"
        errrorfields = data.message
        self.errors = []
        for item of errrorfields
          $log.log("Error in #{item}")
          self.errors.push {key:item, value:errrorfields[item] }

    self.uniqueQuestions = (value) ->
      self.questions.indexOf(value) == -1 ? true : false
        
    self.readyToRegister = () ->
      (self.first_name && self.last_name && self.password_confirmation && self.registrationType)

    self.readyToSend = () ->
      true

    self.sendRegistration = () ->
      self.postToResource 'students',self.form_params()

    self.form_params = () ->
      debugger
      return {
        'first_name': self.first_name
        'last_name':  self.last_name
        'password':   self.password,
        'password_confirmation': self.password_confirmation,
        'email': self.email
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


  # Directive to explicitly set form-model errors from the controller
  # TODO: Maybe this could be moved into a service that round-trips data & errors
  # Use it on a whole FORM element at once like so:
  #   <form qn-validate='some-model-where-errors-will-be-written'>
  .directive 'qnValidate', () ->
    link: (scope, element, attr) ->
      form = element.inheritedData('$formController')
      return unless form
      
      # validation model
      validate = attr.qnValidate
      
      scope.$watch validate, (errors) ->
        form.$serverError = { }
        form.$serverInvalid = false
        
        # set $serverInvalid to true|false
        form.$serverInvalid = (errors.length > 0)
        # loop through errors
        angular.forEach errors, (error, i) ->
          form.$serverError[error.key] = { $invalid: true, message: error.value }
          field = form[error.key]
          if field
            field.$setValidity('server-error', false)
            field.$setViewValue(field.$viewValue || ' ')
            debugger