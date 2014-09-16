angular.module("registrationApp", ["ccDirectives",'ui.select' ])  
  .controller "RegistrationController", [ '$http', ($http) ->
    console.log("we have registered our controller")
    self = @

    self.loadCountries = () ->
      self.loadRemoteCollection('countries')

    self.loadStates = () ->
      self.loadRemoteCollection('states')

    self.loadDisrticts = () ->
      params = { state: self.state }
      self.loadRemoteCollection('districts',params)

    self.loadDomesticSChools = () ->
      params = { district_id : self.district.id }
      console.log("loading domestic schools")
      self.loadRemoteCollection('schools',params)

    self.loadIntlSchools = () ->
      console.log("loading international schools")
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
        console.log("loaded #{collectionName} collection from #{url}")
        self[collectionName] = data

      .error (data, status) ->
          console.log "Error loading #{collectionName} collection"
          self[collectionName] || =[]

    self.isStudent = () ->
      self.registrationType == "student";

    self.isTeacher = () ->
      self.registrationType == "teacher";

    self.readyToRegister = () ->
      return self.first_name && self.last_name && self.confirmPassword && self.registrationType

    self.startRegistration = () ->
      self.didStartRegistration = true
      self.loadCountries()

    self.showTeacherPage = () ->
      return self.didStartRegistration && self.registrationType == "teacher"

    self.showStudentPage = () ->
      return self.didStartRegistration && self.registrationType == "student"

    self.showPage1 = () ->
      !self.didStartRegistration

    self.isDomestic = () ->
      return false unless self.country
      self.country.name == "United States"
    
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