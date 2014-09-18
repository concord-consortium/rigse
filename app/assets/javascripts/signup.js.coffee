angular.module("registrationApp", ["ccDirectives",'ui.select','ui.validate' ])
  .controller "RegistrationController", [ '$scope', '$http', '$log', ($scope,$http,$log) ->
    self = @
    self.chosen_questions = []
    self.errors = []
    
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

    self.postToResource = (resourceName, params={}) ->
      url = API_V1[resourceName.toUpperCase()]
      $http({method: 'POST', url: url, params: params})
      .success (data, status, headers, config) ->
        $log.log("added #{resourceName} to #{url}")
        self[resourceName] = data

      .error (data, status) ->
        $log.log "Error posting #{resourceName} collection"
        errrorfields = data.message
        self.errors = []
        for item of errrorfields
          $log.log("Error in #{item}")
          $log.log($scope)
          # $log.log($scope.$from[item])
          self.errors.push {key:item, value:errrorfields[item] }
        # self[resourceName].errors = data

    self.uniqueQuestions = (value) ->
      if self.chosen_questions.indexOf(value) == -1
        return true
      else
        return false

    self.readyToRegister = () ->
      return self.first_name && self.last_name && self.confirmPassword && self.registrationType

    self.startRegistration = () ->
      self.didStartRegistration = true
      self.loadCountries() if self.registrationType == "teacher"
      self.loadSecurityQuestions() if self.registrationType == "student"
      self.postToResource("#{self.registrationType}s")

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

# Custom directive to compare two fields, and assert that they
# should match... Use like:
#   < input 'match' => "regController.password", … >… </input>
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